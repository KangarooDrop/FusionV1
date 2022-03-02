extends Node2D

var host = false
var online = false
var ip = "127.0.0.1"

var network
var DEFAULT_PORT = 25565
var MAX_PEERS = 2

var otherPlayerData = null
var spectators := []
	
func _OnConnectFailed():
	print("failed to connect to server")
	
func _OnConnectSucceeded():
	print("connected to server")
	get_node("/root/Lobby").startGame()
	

func _Server_Disconnected():
	print("Server diconnected")
	otherPlayerData = null
	
	closeServer()
	
	MessageManager.notify("Opponent disconnected")
	

####################################################################

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
	if otherPlayerData == null:
		otherPlayerData = player_id
		get_node("/root/Lobby").startGame()
	else:
		spectators.append(player_id)
		setSpectateData(player_id, get_node("/root/main/Board").dataLog)
		print("Spectator joined")

	
func playerDisconnected(player_id):
	if player_id == otherPlayerData:
		print("User "+ str(player_id) + " Disconnected")
		otherPlayerData = null
		
		closeServer()
		
		MessageManager.notify("Opponent disconnected")
	elif player_id in spectators:
		print("Spectator  "+ str(player_id) + " Disconnected")
		spectators.erase(player_id)
		
		MessageManager.notify("Spectator disconnected")
		

####################################################################
	
func connectToServer():
	get_tree().connect("connection_failed", self, "_OnConnectFailed")
	get_tree().connect("connected_to_server", self, "_OnConnectSucceeded")
	get_tree().connect("server_disconnected", self, "_Server_Disconnected")
	
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
		print("Board not ready yet, waiting; fetch")
		yield(get_tree().create_timer(0.1), "timeout")
		board = get_node_or_null("/root/main/Board")
		if not Server.online:
			return
		if otherPlayerData != null and player_id != otherPlayerData:
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
	var ids = []
	if Server.host:
		ids.append(otherPlayerData)
		ids += spectators
	else:
		ids.append(1)
	for id in ids:
		if id == otherPlayerData or id == 1:
			rpc_id(id, "serverSlotClicked", isOpponent, slotZone, slotID, button_index)
		else:
			rpc_id(id, "serverSlotClicked", not isOpponent, slotZone, slotID, button_index)
	
remote func serverSlotClicked(isOpponent : bool, slotZone : int, slotID : int, button_index : int):
	var player_id = get_tree().get_rpc_sender_id()
	
	var board = get_node_or_null("/root/main/Board")
	if board.activePlayer == 0 and Settings.gameMode == BoardMP.GAME_MODE.PLAYING:
		return
	board.slotClickedServer(isOpponent, slotZone, slotID, button_index)
	
	if Server.host:
		for id in spectators:
			rpc_id(id, "serverSlotClicked", isOpponent, slotZone, slotID, button_index)
	
####################################################################

remote func onNextTurn():
	var ids = []
	if Server.host:
		ids.append(otherPlayerData)
		ids += spectators
	else:
		ids.append(1)
	for id in ids:
		rpc_id(id, "serverOnNextTurn")
	
remote func serverOnNextTurn():
	var player_id = get_tree().get_rpc_sender_id()
	
	var board = get_node_or_null("/root/main/Board")
	if board.activePlayer == 0 and Settings.gameMode == BoardMP.GAME_MODE.PLAYING:
		return
	board.nextTurn()
		
	if Server.host:
		for id in spectators:
			rpc_id(id, "serverOnNextTurn")

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
		print("Board not ready yet, waiting; active")
		yield(get_tree().create_timer(0.1), "timeout")
		board = get_node_or_null("/root/main/Board")
		if not Server.online:
			return
		if otherPlayerData != null and player_id != otherPlayerData:
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
	Server.online = false
	Server.host = false
	
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

####################################################################

remote func setSpectateData(to : int, data):
	rpc_id(to, "serverSetSpectateData", data)
	
remote func serverSetSpectateData(data):
	if Settings.gameMode != BoardMP.GAME_MODE.SPECTATE:
		MessageManager.notify("The game has already begun")
		Server.closeServer()
		Server.online = false
		var error = get_tree().change_scene("res://Scenes/Networking/Lobby.tscn")
		if error != 0:
			print("Error loading test1.tscn. Error Code = " + str(error))
	else:
		var board = get_node_or_null("/root/main/Board")
		while not is_instance_valid(board):
			print("Board not ready yet, waiting; set spectate")
			yield(get_tree().create_timer(0.1), "timeout")
			board = get_node_or_null("/root/main/Board")
			if not Server.online:
				return
		board.setSpectatorData(data)

####################################################################

remote func spectatorRestart():
	for id in spectators:
		rpc_id(id, "serverSpectatorRestart")
	
remote func serverSpectatorRestart():
	var error = get_tree().change_scene("res://Scenes/main.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))
