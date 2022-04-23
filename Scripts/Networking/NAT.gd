extends Node


func _ready():
	$RabidHolePuncher.connect("holepunch_progress_update", self, "holepunch_progress_update")
	$RabidHolePuncher.connect("holepunch_failure", self, "holepunch_failure")
	$RabidHolePuncher.connect("holepunch_success", self, "holepunch_success")
	
	get_tree().connect("network_peer_connected", self, "playerConnected")
	get_tree().connect("network_peer_disconnected", self, "playerDisconnected")
	
	get_tree().connect("connection_failed", self, "_OnConnectFailed")
	get_tree().connect("connected_to_server", self, "_OnConnectSucceeded")
	get_tree().connect("server_disconnected", self, "_Server_Disconnected")

func _on_HostButton_pressed():
	$RabidHolePuncher.create_session($VBoxContainer/HBoxRoom/LineEdit.text, $VBoxContainer/HBoxUsername/LineEdit.text, 2)

func _on_JoinButton_pressed():
	$RabidHolePuncher.join_session($VBoxContainer/HBoxRoom/LineEdit.text, $VBoxContainer/HBoxUsername/LineEdit.text, 2)

func _on_StartButton_pressed():
	$RabidHolePuncher.start_session()

func holepunch_progress_update(type, session_name, player_names):
	print(type, "  ", session_name, "  ", player_names)

func holepunch_failure(error):
	print("Failure: ", error)

func holepunch_success(self_port, host_ip, host_port):
	print("Success: ", self_port, "  ", host_ip, "  ", host_port)
	
	if host_ip == null:
		start_server(self_port, 2)
	else:
		connect_to_server(host_ip, host_port)

var network

func start_server(port, peers):
	network = NetworkedMultiplayerENet.new()
	var ok = network.create_server(port, peers)
	if ok == OK:
		get_tree().set_network_peer(network)
		print("Server started")
	else:
		print("Server could not be started")

func connect_to_server(host_ip, host_port):
	network = NetworkedMultiplayerENet.new()
	
	var errorStatus = network.create_client(host_ip, host_port)
	print("Trying to connect results in code #" + str(errorStatus))
	get_tree().set_network_peer(network)

func close_server():
	if network != null:
		print("Terminating connection")
		network.close_connection()
	
func playerConnected(player_id : int):
	print("player connected: ", player_id)
	
func playerDisconnected(player_id : int):
	print("player dc'd: ", player_id)
	
func _OnConnectFailed():
	print("failed to connect to server")

func _OnConnectSucceeded():
	print("connected to server")

func _Server_Disconnected():
	print("Server diconnected")

func _exit_tree():
	close_server()
