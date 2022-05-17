""" None """
extends HolePunchState

onready var _server_timer: Timer = $ServerTimer

func _ready():
	yield(owner, "ready")
	_server_timer.wait_time = SERVER_TIMEOUT_SECONDS
	_server_timer.connect("timeout", self, "_on_server_timer_timeout")

func enter(msg: Dictionary = {}) -> void:
	hole_puncher._server.close()
	hole_puncher._peer.close()
	debug("Enter " + self.name + " state")
	if msg.has(ERROR_STR):
		error("HolePunch failed, reason: " + str(msg[ERROR_STR]))
		hole_puncher.emit_signal("holepunch_failure", msg[ERROR_STR])

func get_public_lobbies():
	_server_timer.start()
	info("Getting public lobbies data")
	var kick_message = GET_PUBLIC_LOBBY_PREFIX + ":"
	send_message(kick_message, hole_puncher._server, hole_puncher.relay_server_address, 
				hole_puncher.relay_server_port)

func process(delta: float) -> void:
	if hole_puncher._server.get_available_packet_count() > 0:
		var packet_string = hole_puncher._server.get_packet().get_string_from_utf8()
		if packet_string.begins_with(GET_PUBLIC_LOBBY_PREFIX):
			var lobbyData = (packet_string as String).split(":")
			var rtn = []
			
			for i in range(1, lobbyData.size()):
				var dat = (lobbyData[i] as String)
				if dat.length() > 1:
					var split = dat.split('#')
					rtn.append(split)
					
			hole_puncher.emit_signal("public_lobbies_received", rtn)
			print("Received public lobbies data: ", rtn)
			_server_timer.stop()

func exit() -> void:
	_server_timer.stop()

func _on_server_timer_timeout() -> void:
	_state_machine.transition_to("None", {ERROR_STR : hole_puncher.ERR_SERVER_TIMEOUT})
