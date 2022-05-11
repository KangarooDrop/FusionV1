# Rabid Hole Punch Server

Python Server that allows peer to peer communication via UDP Hole Punching between devices that are behind NAT

**Please note that although UDP Hole Punching is a great technique it is not successful 100% of the time due to different NAT and firewall configurations**

## Requirements

- A public accessible machine with a udp port open
- Python3 installed
- Twisted installed. With Python3 installed you can run the command `pip install twisted` to do this


## Run instructions

Clone this repository to any folder of your choice and run the following command. 

```
python3 main.py <port>
```
Notes:
- Python 3.9 is the Python version recommended, but if you have an earlier 3.x version that should work too
- Replace `<port>` with a port of your choice (must be the same as the port opened for the machine)

Server will start running in the specified port

If some weird behaviour is happening and you want to print more information to debug, you can run the server using

```
python3 main.py <port> DEBUG
```

And it will print more information

The server will generate log files with the name `rabid-hole-punch.log`

## Usage

This server will start listening in the UDP port of your choice and it will wait for requests to arrive

You can implement a client for this server in any game engine of your choice, [but you have one already available for the Godot game engine here](https://gitlab.com/RabidTunes/rabid-hole-punch-godot)

## Description of the workflow (in case you want to implement your own client for this server)

Here is the workflow and the UDP packets you have to send to the server in order to the hole punch process to work:

### 1 (Host) - Create session request - `h:<sessionname>:<playername>:<maxplayers>:<sessionpassword>`

Session name must have between 1-10 alphanumeric characters

Player name must have between 1-12 alphanumeric characters

Max players must be a number between 2 and 12

Session password must have between 1-12 alphanumeric characters. This part is optional

Examples:
`h:NiceRoom:Alice:4:Pass`
`h:NiceRoom:Alice:4` (no password)

After sending this, if the session was created, the server will respond with the following udp message `i:Alice`. It is the info prefix `i` followed by the current list of players (currently just one)

### 1 (Client) - Connect to session request - `c:<sessionname>:<playername>:<sessionpassword>`

Session name must have between 1-10 alphanumeric characters

Player name must have between 1-12 alphanumeric characters

Session password must have between 1-12 alphanumeric characters. This part is optional

Examples:
`c:NiceRoom:Bob:Pass`
`c:NiceRoom:Bob`

After sending this, if the session exists and has enough room for you, the server will respond with the following udp message `i:Alice:Bob`. It is the info prefix `i` followed by the current list of players


### 2 (Everybody) - Ping request - `p:<sessionname>:<playername>`

After creating/connecting to the session, you have to send regularly some pings, otherwise the server will kick you out. Sending one ping at least each second will suffice in most cases.

Examples:
`p:NiceRoom:Alice`
`p:NiceRoom:Bob`

### 3 (Host) - Start Session - `s:<sessionname>:<playername>`

When enough players have connected, as host you can send this message so the server will answer with the IPs and ports of all peers. Sending this message will make the server start sending the start message to all peers. The start message changes depending on the receiver, for example, if a session has 3 players, Alice, Bob and Carol:
- Alice will receive this message: `s:<AlicePort>:Bob:<BobIP>:<BobPort>;Carol:<CarolIP>:<CarolPort>`
- Bob will receive this message: `s:<BobPort>:Alice:<AliceIP>:<AlicePort>;Carol:<CarolIP>:<CarolPort>`
- Carol will receive this message: `s:<CarolPort>:Alice:<AliceIP>:<AlicePort>;Bob:<BobIP>:<BobPort>`

If a non-host player receives this message, it is safe to assume that the first player that receives in this message is the host. Both Bob and Carol received 'Alice' as first player in the list, so they will assume that's the host.

### 4 (Everybody) - Confirm Start Session info received - `y:<sessionname>:<playername>`

After receiving the list of players message, it is nice to send a confirmation to let the server know that we received the info, so it stops sending us the start session message. It is not only to save resources, but to prevent it to spam our ports.

Example:
`y:NiceRoom:Alice`

After sending this message, the communications with this relay server should be finished. [Check out this section to see what's next.](https://gitlab.com/RabidTunes/rabid-hole-punch-server#what-to-do-after-receiving-the-players-ips-and-ports)

### Optional message in session (Host) - Kick player from session - `k:<sessionname>:<player-name-to-kick>`

If you are the host you can kick a player by sending this message to the server. In the current version this won't prevent the player to re-enter the session, unfortunately.

Example:
`k:NiceRoom:Bob`

### Optional message in session (Everybody) - Exit session - `x:<sessionname>:<playername>`

You can send this message in any given time inside a session that has not started yet to exit that session.

Example:
`x:NiceRoom:Carol`

## Error codes sent by the server

### ERR_REQUEST_INVALID = "error:invalid_request"
Bad formatted request. Probably some characters are invalid or the names too long
### ERR_SESSION_EXISTS = "error:session_exists"
Tried to create a session with a name that already exists
### ERR_SESSION_NON_EXISTENT = "error:session_non_existent"
Tried to connect to a session that does not exist anymore
### ERR_SESSION_PASSWORD_MISMATCH = "error:password_mismatch"
Passwords do not match
### ERR_SESSION_SINGLE_PLAYER = "error:only_one_player_in_session"
Tried to start a session with one player only
### ERR_SESSION_FULL = "error:session_full"
Tried to join a session that's full
### ERR_SESSION_PLAYER_NAME_IN_USE = "error:player_name_in_use"
Tried to join a session with a player name that is already in use
### ERR_SESSION_PLAYER_NON_EXISTENT = "error:non_existent_player"
Tried to update or kick a player that does not exist in the given session
### ERR_SESSION_PLAYER_NON_HOST = "error:non_host_player"
Tried to execute a command with a player that is not host
### ERR_SESSION_PLAYER_KICKED_BY_HOST = "error:kicked_by_host"
Kicked by host
### ERR_SESSION_PLAYER_EXIT = "error:player_exited_session"
Sent when a player exits the session
### ERR_SESSION_NOT_STARTED = "error:session_not_started"
Sent when player sends confirmation for a non-started session
### ERR_SESSION_TIMEOUT = "error:session_timeout"
Session timed out (sessions have a max time to live)
### ERR_PLAYER_TIMEOUT = "error:player_timeout"
Player timed out (too much time without sending a ping)

## What to do after receiving the players ips and ports

Once you receive the IPs and ports of all players, the communication with the server should end. Now you have to start sending messages to the other peers. Since you will be implementing your own communication between peers, the message you send is free format. As long as it is UDP, it should be ok. If you need an example of the messages sent, you can check the [Godot plugin](https://gitlab.com/RabidTunes/rabid-hole-punch-godot).

In this phase, the workflow is as follows:

### Sending greetings

In this phase, each peer should start listening on the port that the server sent as the "own port" (Remember that the server sent a message like `s:<ownport>:<other_players_addresses...>`). Once they do this, each peer has the ip address and the port of the other peers, but because of how some NATs work, it could happen that the NAT opens a different port for security reasons, so we are not really 100% sure that the ports that the server sent us as the "others' peers" ports. Some routers change the ports opened and assign a new one that's slightly above or below the one opened for the communication with the server.

For this reason, each peer should send multiple messages to other peers. For each peer it should be sent a message containing at least the port used to send that message to that specific peer. Since we do not know for sure the port, we should also have a **window of ports to test**. Something like port received +- 8.

Example:
Let's say Alice received that their port is 1234 and also received that Bob's port is 5555. Alice should listen to port 1234 and start sending UDP messages to Bob's IP. Regarding Bob's port, Alice should first start trying the port 5555, but they should also send some messages on near ports just to be sure that the greeting packet arrives. 

So Alice will test sending that message to the ports 5547, 5548, 5549, 5550, 5551, 5552, 5553, 5554, 5556, 5557, 5558, 5559, 5560, 5561, 5562 and 5563. It is extremely important that on each message the port sent is the port used to send that message, so when Bob receives the message, they can know which port the other peer used to reach them.

After receiving enough greetings, each peer can decide what is the port they should use for communications. If the server said that a peer's port is 1234 but all greetings were received on poert 1240, that port should be used instead, so you should close the previously opened port for listening and change the port.

After this you can move on to the next phase.

### Sending confirmations

After finishing sending greetings, each peer can be sure about one thing: their own port. The previous phase goal was to confirm the port opened for each peer. But each peers still doesn't know what is the confirmed port of the other peers.

That's why in this stage we will send each peer confirmed port to other peers, so the other peers know what is the confirmed port for each peer. So for example if Alice confirme that their port is 1234, they should send to the others that port number alongside their name.

But here's the catch: we still don't know the confirmed port for the others, so we still do have to send the confirmations inside a window of ports to be sure that our message reaches the others.

Example:
Let's say Alice confirmed that their port is 1234. Bob however noticed that the server said that their port is 5555 but all the greetings were received on port 5560 instead. Alice will keep listening on port 1234 but Bob will switch to port 5560.

After this, Alice will send messages to Bob with the port 1234 so Bob can confirm that Alice's port is 1234... but Alice messages will initially fail, because Alice first attempt will be at port 5555 and Bob knows that this port is no good! This is why Alice should try nearby ports so the message will reach Bob at some point.

Bob however will send message to Alice with the confirmed port 5560, and this message will reach Alice with no issues with the first port attempted (1234) as this port hasn't changed.

One thing Alice (and any player) should do to speed up the confirmation process is, when Alice receives Bob's confirmation message, is to stop testing nearby ports and just use the port that Bob has confirmed for them.

Remember: **Greetings phase is about confirming each peer's _own port_. Confirmations phase is about confirming _other's port_.**


### Starting server and communicating

Once every peer has confirmed other's peer ports, the host can start the multiplayer server and the peers can connect to the host! It is recommended that the port used by clients for communication is the one confirmed in the previous stage. Some engines allow specifying which port will be used as the listening one when connecting to the server.

## Problems when communicating with other peers

Just like with the relay server it could happen that some problems arise when communicating with other peers, even with what we did to try to mitigate issues. A few common problems you can have are:

### Some client peers are not reachable

If a peer does not receive any greeting in the greetings phase, they can consider that they are unreachable and unfortunately, this holepunch system is not a good fit for them

### Host is unreachable

Imagine some peers receive greets from each other so they have enough greetings to confirm their own port, but when reaching the confirmations phase, the host never confirms its own port. This is a problem because you cannot have a multiplayer match without a host. A possible solution to this (which is not implemented right now in the Godot plugin by the way) is to change the player that will act as the host on the fly, although it can be difficult since every player should decide who will be the new host.

# Credits

Credits to [SLGamesCregg](https://github.com/SLGamesCregg) for his [Godot HolePuncher plugin](https://godotengine.org/asset-library/asset/608), because this Hole Punch Server was initially based upon his server python file, which was based upon [stylesuxx udp hole punching server](https://github.com/stylesuxx/udp-hole-punching/).
