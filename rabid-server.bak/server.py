"""
This class is the one handling the requests and rerouting them
to the correspondent handler function
"""
from typing import Tuple

from twisted.internet import reactor
from twisted.internet.defer import inlineCallbacks
from twisted.internet.protocol import DatagramProtocol
from twisted.internet.task import deferLater

import logger
import re
from errors import *
from model import Session, Player, InvalidRequest, IgnoredRequest

UDP_MESSAGE_SECONDS_BETWEEN_TRIES: float = 0.05
SESSION_CLEANUP_SCHEDULED_SECONDS: float = 60 * 5
PLAYER_CLEANUP_SCHEDULED_SECONDS: float = 8
CONFIRMATION_RETRIES: int = 8
SECONDS_BETWEEN_CONFIRMATION_RETRIES: float = 0.1

SESSION_NAME_REGEX = "[A-Za-z0-9]{1,10}"
PLAYER_NAME_REGEX = "[A-Za-z0-9]{1,12}"
MAX_PLAYERS_REGEX = "([2-9]|1[0-2])"
SESSION_PASS_REGEX = "[A-Za-z0-9]{1,12}"

SESSION_PLAYER_REGEX = "^" + SESSION_NAME_REGEX + ":" + PLAYER_NAME_REGEX + "$"
SESSION_PLAYER_PASS_REGEX = "^" + SESSION_NAME_REGEX + ":" + PLAYER_NAME_REGEX + "(:" + SESSION_PASS_REGEX + ")?$"
SESSION_HOST_REGEX = "^" + SESSION_NAME_REGEX + ":" + PLAYER_NAME_REGEX + ":" + MAX_PLAYERS_REGEX \
                     + "(:" + SESSION_PASS_REGEX + ")?$"


class Server(DatagramProtocol):

    def __init__(self):
        self.active_sessions = {}
        self.starting_sessions = {}
        self.logger = logger.get_logger("Server")
        self.message_handlers = {"h": self.host_session, "c": self.connect_session, "p": self.player_ping,
                                 "k": self.kick_player, "x": self.exit_session, "s": self.start_session,
                                 "y": self.confirm_player, "m": self.chat_message, "d":self.set_lobby_data,
                                 "l": self.get_public_info}
        reactor.callLater(SESSION_CLEANUP_SCHEDULED_SECONDS, self.cleanup_sessions)
        reactor.callLater(PLAYER_CLEANUP_SCHEDULED_SECONDS, self.cleanup_players)

    def datagramReceived(self, datagram, address):
        datagram_string = datagram.decode("utf-8")
        self.logger.debug("Received datagram %s", datagram_string)

        try:
            message_type, message = self.parse_datagram_string(datagram_string, address)
            if message_type not in self.message_handlers.keys():
                print("Error: invalid request")
                raise InvalidRequest
            self.message_handlers[message_type](message, address)
        except IgnoredRequest:
            pass
        except InvalidRequest as e:
            self.logger.debug("Invalid request: %s", str(e))
        except Exception as e:
            self.logger.error("Uncontrolled error: %s", str(e))

    def parse_datagram_string(self, data_string: str, address: Tuple) -> Tuple:
        split = data_string.split(":", 1)
        if len(split) != 2:
            self.logger.debug("Invalid datagram received %s", data_string)
            self.send_message(address, ERR_REQUEST_INVALID)
            raise InvalidRequest(f"Invalid datagram received {data_string}")
        return split[0], split[1]

    """
    Commands handling methods
    """
    def host_session(self, message: str, address: Tuple):
        session_name, player_name, max_players, password = self.parse_host_request(message, address)
        ip, port = address
        self.logger.debug("Received request from player %s to host session %s for max %s players. Source: %s:%s",
                          player_name, session_name, max_players, ip, port)

        self.check_host_session(session_name, address)

        self.active_sessions[session_name] = Session(session_name, max_players, Player(player_name, ip, port), password)
        self.logger.info("Created session %s (max %s players)", session_name, max_players)
        self.send_session_info(address, self.active_sessions[session_name])

    def connect_session(self, message: str, address: Tuple):
        session_name, player_name, session_password = self.parse_connect_request(message, address)
        ip, port = address
        self.logger.debug("Received request from player %s to connect to session %s. Source: %s:%s",
                          player_name, session_name, ip, port)

        self.check_connect_session(session_name, session_password, player_name, address)

        session = self.active_sessions[session_name]
        session.add_player(Player(player_name, ip, port))
        self.logger.info("Connected player %s to session %s", player_name, session_name)
        self.broadcast_session_info(session)

    def player_ping(self, message: str, address: Tuple):
        session_name, player_name = self.parse_session_player_from(message, address)
        ip, port = address
        self.logger.debug("Received ping from player %s from session %s. Source: %s:%s",
                          player_name, session_name, ip, port)

        if session_name in self.starting_sessions.keys() \
                and player_name in self.starting_sessions[session_name].players.keys():
            self.logger.debug("Session %s is starting, sending addresses", session_name)
            session = self.starting_sessions[session_name]
            player = session.players[player_name]
            self.send_message(address, f"s:{player.port}:{session.get_session_players_addresses_except(player)}")
            return
        self.check_active_session(session_name, address)
        session = self.active_sessions[session_name]
        self.check_player_exists_in(session, player_name, address)

        session.players[player_name].update_last_seen()
        self.send_session_info(address, session)

    def kick_player(self, message: str, address: Tuple):
        session_name, player_name = self.parse_session_player_from(message, address)
        ip, port = address
        self.logger.debug("Received command to kick player %s from session %s. Source: %s:%s",
                          player_name, session_name, ip, port)

        self.check_active_session(session_name, address)
        session = self.active_sessions[session_name]
        self.check_player_exists_in(session, player_name, address)
        self.check_player_is_host(session, address)

        player = session.players[player_name]
        session.remove_player(player_name)
        self.send_message((player.ip, player.port), ERR_SESSION_PLAYER_KICKED_BY_HOST)
        self.logger.info("Kicked player %s from session %s", player_name, session_name)
        if not session.players_array:
            del self.active_sessions[session_name]
            self.logger.info("No more players in session %s, deleted session", session_name)
        self.broadcast_session_info(session)

    def exit_session(self, message: str, address: Tuple):
        session_name, player_name = self.parse_session_player_from(message, address)
        ip, port = address
        self.logger.debug("Received command to exit session %s from player %s. Source: %s:%s",
                          session_name, player_name, ip, port)

        self.check_active_session(session_name, address)
        session = self.active_sessions[session_name]
        self.check_player_exists_in(session, player_name, address)

        session.remove_player(player_name)
        self.send_message(address, ERR_SESSION_PLAYER_EXIT)
        self.logger.info("Player %s exited session %s", player_name, session_name)
        if not session.players_array:
            del self.active_sessions[session_name]
            self.logger.info("No more players in session %s, deleted session", session_name)

    @inlineCallbacks
    def start_session(self, message: str, address: Tuple):
        # TryExcept is required because @inlineCallbacks wraps this piece of code so
        # external TryExcept won't catch exceptions thrown here
        try:
            session_name, source_player_name = self.parse_session_player_from(message, address)
            ip, port = address
            self.logger.debug("Received start session %s from player %s Source: %s:%s",
                              session_name, source_player_name, ip, port)

            if session_name in self.starting_sessions.keys():
                self.logger.debug("Session %s already started", session_name)
                return
            self.check_active_session(session_name, address)
            session = self.active_sessions[session_name]
            self.check_player_is_host(session, address)
            if len(session.players_array) == 1:
                self.logger.debug("Cannot start session %s with only one player", session_name)
                self.send_message(address, ERR_SESSION_SINGLE_PLAYER)
                raise InvalidRequest(f"Cannot start session {session_name} with only one player")

            del self.active_sessions[session_name]
            self.starting_sessions[session_name] = session
            for i in range(CONFIRMATION_RETRIES):
                if session.players_array:
                    for player_name in list(session.players.keys()):
                        if player_name in session.players.keys():
                            player = session.players[player_name]
                            self.send_message((player.ip, player.port),
                                              f"s:{player.port}:{session.get_session_players_addresses_except(player)}")
                    yield sleep(SECONDS_BETWEEN_CONFIRMATION_RETRIES)
            del self.starting_sessions[session_name]
            self.logger.info("All addresses sent for session %s. Session closed.", session_name)
        except IgnoredRequest:
            pass
        except InvalidRequest as e:
            self.logger.debug("Invalid request: %s", str(e))
        except Exception as e:
            self.logger.error("Uncontrolled error: %s", str(e))

    def confirm_player(self, message: str, address: Tuple):
        session_name, player_name = self.parse_session_player_from(message, address)
        ip, port = address
        self.logger.debug("Received confirmation about addresses reception for session %s from player %s Source: %s:%s",
                          session_name, player_name, ip, port)

        self.check_starting_session(session_name, address)
        session = self.starting_sessions[session_name]
        self.check_player_exists_in(session, player_name, address)

        session.remove_player(player_name)
        self.logger.info("Player %s from session %s received other players' addresses", player_name, session_name)

    def chat_message(self, message: str, address: Tuple):
        s_split = message.split(':', 2)
        chat = s_split[1] + ":" + s_split[2]
        message = s_split[0] + ":" + s_split[1]

        session_name, player_name = self.parse_session_player_from(message, address)
        ip, port = address
        self.logger.debug("Received command to send chat message: %s",
                          chat)

        self.check_active_session(session_name, address)
        session = self.active_sessions[session_name]

        for player_name in session.players.keys():
            player = session.players[player_name]
            self.send_message((player.ip, player.port), "m:" + chat)
        self.broadcast_session_info(session)


    def get_public_info(self, message: str, address: Tuple):
        ip, port = address
        session_data = []

        for key, session in self.active_sessions.items():
            if session.is_public():
                session_data.append('#'.join(session.get_public_info()))

        self.send_message((ip, port), "l:" + ":".join(session_data))

    def set_lobby_data(self, message: str, address: Tuple):
        session_name, player_name = self.parse_session_player_from(message, address)
        ip, port = address

        self.check_active_session(session_name, address)
        session = self.active_sessions[session_name]
        self.check_player_is_host(session, address)

        s_split = message.split(':')
        s_split.pop(0)
        print(s_split, "  ", s_split[0], "  ", s_split[0] == "True")
        s_split[0] = s_split[0] == "True"

        session.lobby_info = s_split

        print(f"Setting session data to\"{message}\"")

    """
    Message sending helper methods
    """
    def broadcast_session_info(self, session: Session):
        for player in session.players_array:
            self.send_session_info((player.ip, player.port), session)

    def send_session_info(self, address: Tuple, session: Session):
        self.send_message(address, f"i:{session.get_session_players_names()}")

    @inlineCallbacks
    def send_message(self, address: Tuple, message: str, retries: int = 1):
        # TryExcept is required because @inlineCallbacks wraps this piece of code so
        # external TryExcept won't catch exceptions thrown here
        try:
            if retries <= 1:
                self.transport.write(bytes(message, "utf-8"), address)
                return

            for i in range(retries):
                self.transport.write(bytes(message, "utf-8"), address)
                yield sleep(UDP_MESSAGE_SECONDS_BETWEEN_TRIES)
        except Exception as e:
            self.logger.error("Uncontrolled error: %s", str(e))

    """
    Parse messages helper methods 
    """
    def parse_session_player_from(self, message: str, source_address: Tuple) -> Tuple:
        split = message.split(':')
        msg_string = split[0] + ":" + split[1]

        if not re.search(SESSION_PLAYER_REGEX, msg_string):
            self.send_message(source_address, ERR_REQUEST_INVALID)
            self.logger.debug("Invalid session/player message received %s", message)
            raise InvalidRequest(f"Invalid session/player message received {message}")
       # Session, Player
        return split[0], split[1]

    def parse_host_request(self, host_request: str, source_address: Tuple) -> Tuple:
        if not re.search(SESSION_HOST_REGEX, host_request):
            self.send_message(source_address, ERR_REQUEST_INVALID)
            self.logger.debug("Invalid session/player message received %s", host_request)
            raise InvalidRequest(f"Invalid session/player message received {host_request}")
        split = host_request.split(":")
        if len(split) == 3:
            # Session, Player, MaxPlayers
            return split[0], split[1], int(split[2]), None
        else:
            # Session, Player, MaxPlayers, Password
            return split[0], split[1], int(split[2]), split[3]

    def parse_connect_request(self, connect_request: str, source_address: Tuple) -> Tuple:
        if not re.search(SESSION_PLAYER_PASS_REGEX, connect_request):
            self.send_message(source_address, ERR_REQUEST_INVALID)
            self.logger.debug("Invalid session/player message received %s", connect_request)
            raise InvalidRequest(f"Invalid session/player message received {connect_request}")
        split = connect_request.split(":")
        if len(split) == 2:
            # Session, Player
            return split[0], split[1], None
        else:
            # Session, Player, Password
            return split[0], split[1], split[2]

    """
    Checker methods
    """
    def check_host_session(self, session_name: str, address: Tuple):
        ip, port = address
        if session_name in self.starting_sessions:
            self.logger.debug("Session %s is already created and started", session_name)
            self.send_message(address, ERR_SESSION_EXISTS)
            raise InvalidRequest(f"Session {session_name} already exists but is started")

        if session_name in self.active_sessions:
            self.logger.debug("Session %s is already created", session_name)
            session = self.active_sessions[session_name]
            if session.host.ip == ip and session.host.port == port:
                self.send_session_info(address, session)
                raise IgnoredRequest
            else:
                self.logger.debug("A different player is trying to create the same session")
                self.send_message(address, ERR_SESSION_EXISTS)
                raise InvalidRequest(f"A different player is trying to create the same session {session_name}")

    def check_connect_session(self, session_name: str, session_password: str, player_name: str, address: Tuple):
        ip, port = address
        self.check_active_session(session_name, address)
        session = self.active_sessions[session_name]
        if not session.password_match(session_password):
            self.logger.debug("Session password for session %s does not match", session_name)
            self.send_message(address, ERR_SESSION_PASSWORD_MISMATCH)
            raise InvalidRequest(f"Session password for session {session_name} does not match")
        if session.is_full():
            self.logger.debug("Session %s is full", session_name)
            self.send_message(address, ERR_SESSION_FULL)
            raise InvalidRequest(f"Session {session_name} is full")
        if player_name in session.players.keys():
            if ip == session.players[player_name].ip and port == session.players[player_name].port:
                self.logger.debug("Player %s is already into session %s", player_name, session_name)
                self.send_session_info(address, session)
                raise IgnoredRequest
            else:
                self.logger.debug("Session %s already has a player with the exact same name (%s) coming from "
                                  "a different ip and port", session_name, player_name)
                self.send_message(address, ERR_SESSION_PLAYER_NAME_IN_USE)
                raise InvalidRequest(f"Session {session_name} already has a player with the exact same ID "
                                     f"({player_name}) coming from a different ip and port")

    def check_active_session(self, session_name: str, address: Tuple):
        if session_name not in self.active_sessions.keys():
            self.logger.debug("Session %s doesn't exist", session_name)
            self.send_message(address, ERR_SESSION_NON_EXISTENT)
            raise InvalidRequest(f"Session {session_name} doesn't exist")

    def check_starting_session(self, session_name: str, address: Tuple):
        if session_name not in self.starting_sessions.keys():
            self.logger.debug("Session %s is not starting", session_name)
            self.send_message(address, ERR_SESSION_NOT_STARTED)
            raise InvalidRequest(f"Session {session_name} is not starting")

    def check_player_exists_in(self, session: Session, player_name: str, address: Tuple):
        if player_name not in session.players:
            self.logger.debug("Player %s doesn't exist in the given session %s", player_name, session.name)
            self.send_message(address, ERR_SESSION_PLAYER_NON_EXISTENT)
            raise InvalidRequest(f"Player {player_name} doesn't exist in the given session {session.name}")

    def check_player_is_host(self, session: Session, address: Tuple):
        if not session.is_host(address):
            ip, port = address
            self.logger.debug("Player %s:%s is not host, cannot perform request", ip, port)
            self.send_message(address, ERR_SESSION_PLAYER_NON_HOST)
            raise InvalidRequest(f"Player {ip}:{port} is not host, cannot perform request")

    """
    Async background tasks
    """
    def cleanup_sessions(self):
        if self.active_sessions:
            self.logger.debug("Starting session cleanup")
        for session_name in list(self.active_sessions.keys()):
            session = self.active_sessions[session_name]
            if session.is_timed_out():
                del self.active_sessions[session_name]
                for player in session.players_array:
                    self.send_message((player.ip, player.port), ERR_SESSION_TIMEOUT, 3)
                self.logger.info("Session %s deleted because it timed out", session.name)
        reactor.callLater(SESSION_CLEANUP_SCHEDULED_SECONDS, self.cleanup_sessions)

    def cleanup_players(self):
        if self.active_sessions:
            self.logger.debug("Starting player cleanup")
        for session_name in list(self.active_sessions.keys()):
            session = self.active_sessions[session_name]
            to_kick = [player for player in session.players_array if player.is_timed_out()]
            for player in to_kick:
                session.remove_player(player.name)
                self.send_message((player.ip, player.port), ERR_PLAYER_TIMEOUT, 3)
                self.logger.info("Kicked player %s from session %s because it timed out", player.name, session.name)
            if not session.players_array:
                del self.active_sessions[session_name]
                self.logger.info("No more players in session %s, deleted session", session_name)
                continue
            if to_kick:
                self.broadcast_session_info(session)
        reactor.callLater(PLAYER_CLEANUP_SCHEDULED_SECONDS, self.cleanup_players)


# Helper method to pause execution for n seconds
def sleep(seconds):
    return deferLater(reactor, seconds, lambda: None)
