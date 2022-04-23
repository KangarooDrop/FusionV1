extends Node


func _ready():
	$RabidHolePuncher.connect("holepunch_progress_update", self, "holepunch_progress_update")
	$RabidHolePuncher.connect("holepunch_failure", self, "holepunch_failure")
	$RabidHolePuncher.connect("holepunch_success", self, "holepunch_success")
	pass
#	$HolePunch.connect("hole_punched", self, "onHolePunch")
#	$HolePunch.connect("session_registered", self, "onSessionRegistered")

func _on_HostButton_pressed():
	$RabidHolePuncher.create_session($VBoxContainer/HBoxRoom/LineEdit.text, $VBoxContainer/HBoxUsername/LineEdit.text, 2)
	pass
	#connectToRoom(true)

func _on_JoinButton_pressed():
	$RabidHolePuncher.join_session($VBoxContainer/HBoxRoom/LineEdit.text, $VBoxContainer/HBoxUsername/LineEdit.text, 2)
	pass
	#connectToRoom(false)

func _on_StartButton_pressed():
	$RabidHolePuncher.start_session()

func connectToRoom(is_host):
	pass
#	$HolePunch._exit_tree()
#	$HolePunch.start_traversal($VBoxContainer/HBoxRoom/LineEdit.text, is_host, $VBoxContainer/HBoxUsername/LineEdit.text)

func onHolePunch(my_port, hosts_port, hosts_address):
	print(my_port, "  ", hosts_port, "  ", hosts_address)

func onSessionRegistered():
	print("Session registered")

func holepunch_progress_update(type: String, session_name: String, player_names: Array):
	print(type, "  ", session_name, "  ", player_names)

func holepunch_failure(error: String):
	print("Failure: ", error)

func holepunch_success(self_port: int, host_ip: String, host_port: int):
	print("Success: ", self_port, "  ", host_ip, "  ", host_port)
