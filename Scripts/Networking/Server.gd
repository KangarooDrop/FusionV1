extends Node2D

var host = false
var online = false
var ip = "127.0.0.1"

var network
var DEFAULT_PORT = 25565
var MAX_PEERS = 1

var otherPlayerData = null
	
func _OnConnectFailed():
	print("failed to connect to server")
	
func _OnConnectSucceeded():
	print("connected to server")
	
	get_node("/root/Lobby").startGame()


func startServer():
	network = NetworkedMultiplayerENet.new()
	network.create_server(DEFAULT_PORT, MAX_PEERS)
	get_tree().set_network_peer(network)
	print("Server started")
	
	get_tree().connect("network_peer_connected", self, "playerConnected")
	get_tree().connect("network_peer_disconnected", self, "playerDisconnected")
	
func closeServer():
	network.close_connection()
	online = false
	host = false
	
func playerConnected(player_id):
	print("User "+ str(player_id) + " Connected")
	otherPlayerData = player_id
	
	get_node("/root/Lobby").startGame()

	
func playerDisconnected(player_id):
	print("User "+ str(player_id) + " Disconnected")
	otherPlayerData = null

####################################################################
	
func connectToServer():
	get_tree().connect("connection_failed", self, "_OnConnectFailed")
	get_tree().connect("connected_to_server", self, "_OnConnectSucceeded")
	
	network = NetworkedMultiplayerENet.new()
	
	otherPlayerData = null
	
	var errorStatus = network.create_client(ip, DEFAULT_PORT)
	print("Trying to connect results in code #" + str(errorStatus))
	get_tree().set_network_peer(network)

####################################################################

remote func fetchDeck(requester):
	var id = 1
	if Server.host:
		id = otherPlayerData
	else:
		pass
	rpc_id(id, "serverFetchDeck", requester)
	
remote func serverFetchDeck(requester):
	var player_id = get_tree().get_rpc_sender_id()
	
	var board = get_node_or_null("/root/main/Board")
	while not is_instance_valid(board) or board.gameStarted:
		print("Board not ready yet, waiting")
		yield(get_tree().create_timer(0.1), "timeout")
		board = get_node_or_null("/root/main/Board")
		if not Server.online:
			return
	var data = board.players[0].deck.getJSONData()
	var order = board.players[0].deck.serialize()
		
	rpc_id(player_id, "returnDeck", data, order, requester)

remote func returnDeck(data, order, requester):
	var inst = instance_from_id(requester)
	if inst:
		inst.setDeckData(data, order)
	else:
		print("AAAAAAAAAAAAAAAAAAAAAAAAAAA! NO REQ")

####################################################################

remote func onGameStart():
	var id = 1
	if Server.host:
		id = otherPlayerData
	else:
		pass
	rpc_id(id, "serverOnGameStart")
	
remote func serverOnGameStart():
	var player_id = get_tree().get_rpc_sender_id()
	
	var board = get_node_or_null("/root/main/Board")
	board.onGameStart()

####################################################################

remote func slotClicked(isOpponent : bool, slotZone : int, slotID : int, button_index : int):
	var id = 1
	if Server.host:
		id = otherPlayerData
	else:
		pass
	rpc_id(id, "serverSlotClicked", isOpponent, slotZone, slotID, button_index)
	
remote func serverSlotClicked(isOpponent : bool, slotZone : int, slotID : int, button_index : int):
	var player_id = get_tree().get_rpc_sender_id()
	
	var board = get_node_or_null("/root/main/Board")
	board.slotClickedServer(isOpponent, slotZone, slotID, button_index)

####################################################################

remote func onNextTurn():
	var id = 1
	if Server.host:
		id = otherPlayerData
	else:
		pass
	rpc_id(id, "serverOnNextTurn")
	
remote func serverOnNextTurn():
	var player_id = get_tree().get_rpc_sender_id()
	
	var board = get_node_or_null("/root/main/Board")
	board.nextTurn()
		

####################################################################

remote func onRestart():
	var id = 1
	if Server.host:
		id = otherPlayerData
	else:
		pass
	rpc_id(id, "serverOnRestart")
	
remote func serverOnRestart():
	var player_id = get_tree().get_rpc_sender_id()
	
	var board = get_node_or_null("/root/main/Board")
	board.onRestartPressed()
		

####################################################################

remote func setActivePlayer(index : int):
	var id = 1
	if Server.host:
		id = otherPlayerData
	else:
		pass
	rpc_id(id, "serverSetActivePlayer", index)
	
remote func serverSetActivePlayer(index : int):
	var player_id = get_tree().get_rpc_sender_id()
	
	var board = get_node_or_null("/root/main/Board")
	while not is_instance_valid(board) or board.gameStarted:
		print("Board not ready yet, waiting")
		yield(get_tree().create_timer(0.1), "timeout")
		board = get_node_or_null("/root/main/Board")
		if not Server.online:
			return
	board.setStartingPlayer(index)

####################################################################

remote func disconnectMessage(message : String):
	var id = 1
	if Server.host:
		id = otherPlayerData
	else:
		pass
	rpc_id(id, "serverDisconnectMessage", message)
	
remote func serverDisconnectMessage(message : String):
	Server.closeServer()
	
	MessageManager.notify(message)
	
	var error = get_tree().change_scene("res://Scenes/StartupScreen.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))

####################################################################

remote func fetchVersion(requester):
	var id = 1
	if Server.host:
		id = otherPlayerData
	else:
		pass
	rpc_id(id, "serverFetchVersion", requester)
	
remote func serverFetchVersion(requester):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "returnVersion", Settings.versionID, requester)

remote func returnVersion(version, requester):
	var inst = instance_from_id(requester)
	if inst:
		inst.compareVersion(version)
	else:
		print("AAAAAAAAAAAAAAAAAAAAAAAAAAA! NO REQ")
		

