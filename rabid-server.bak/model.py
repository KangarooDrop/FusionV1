"""
Data classes to facilitate operations by the server
"""

import time
from typing import List, Dict, Tuple

PLAYER_TIMEOUT_MSECS = 5 * 1000
SESSION_TIMEOUT_MSECS = 15 * 60 * 1000


def current_time_millis():
    return int(time.time() * 1000)


class Player:

    def __init__(self, name: str, ip: str, port: int):
        self.name = name
        self.ip = ip
        self.port = port
        self.last_seen = current_time_millis()

    def is_timed_out(self):
        return current_time_millis() - self.last_seen > PLAYER_TIMEOUT_MSECS

    def update_last_seen(self):
        self.last_seen = current_time_millis()

    def __eq__(self, other):
        if other is None:
            return False
        return self.name == other.name

    def __ne__(self, other):
        return not self.__eq__(other)

    def __str__(self):
        return f"Player({self.name}, {self.ip}, {self.port}, {self.last_seen})"


class Session:

    def __init__(self, name: str, max_players: int, host: Player, password: str = None):
        self.name: str = name
        self.max_players: int = max_players
        self.host: Player = host
        self.players: Dict = {host.name: host}
        self.players_array: List = [host]
        self.password: str = password
        self.started_at: int = current_time_millis()
        self.lobby_info: List = [False, ""]

    def is_public(self) -> bool:
        return self.lobby_info[0]

    def is_timed_out(self) -> bool:
        return current_time_millis() - self.started_at > SESSION_TIMEOUT_MSECS

    def is_full(self) -> bool:
        return len(self.players_array) == self.max_players

    def add_player(self, player: Player):
        if len(self.players_array) < self.max_players and player.name not in self.players:
            self.players_array.append(player)
            self.players[player.name] = player

    def get_session_players_names(self) -> str:
        return ":".join([player.name for player in self.players_array])

    def get_session_players_addresses_except(self, current_player: Player) -> str:
        return ";".join([f"{player.name}:{player.ip}:{player.port}" for player in self.players_array
                         if player.name != current_player.name])

    def password_match(self, input_password: str) -> bool:
        if self.password is None:
            return True
        if input_password is None:
            return False
        return self.password == input_password

    def is_host(self, address: Tuple) -> bool:
        ip, port = address
        return self.host.ip == ip and self.host.port == port

    def remove_player(self, player_name: str):
        del self.players[player_name]
        self.players_array = [player for player in self.players_array if player.name != player_name]
        if self.players_array:
            self.host = self.players_array[0]
        else:
            self.host = None

    def get_public_info(self) -> List:
        return [self.players_array[0].name, self.name, f"{len(self.players_array)} / {self.max_players}", self.lobby_info[1]]

    def __eq__(self, other):
        if other is None:
            return False
        return self.name == other.uuid

    def __ne__(self, other):
        return not self.__eq__(other)

    def __str__(self):
        return f"Session({self.name}, {self.max_players}, {self.host}, {self.players}, {self.started_at})"


class InvalidRequest(Exception):
    pass


class IgnoredRequest(Exception):
    pass
