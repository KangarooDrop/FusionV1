extends Node2D

var username := "NO_NAME"

var host = false
var online = false
var ip = "127.0.0.1"

var network : NetworkedMultiplayerENet
const DEFAULT_PORT := 25565
var MAX_PEERS := 5

var playerIDs := []
var playerNames := {}

func _ready():
	get_tree().connect("network_peer_connected", self, "playerConnected")
	get_tree().connect("network_peer_disconnected", self, "playerDisconnected")
	
	get_tree().connect("connection_failed", self, "_OnConnectFailed")
	get_tree().connect("connected_to_server", self, "_OnConnectSucceeded")
	get_tree().connect("server_disconnected", self, "_Server_Disconnected")

####################################################################

func startServer():
	var peers = MAX_PEERS
	if Settings.gameMode == Settings.GAME_MODE.LOBBY_PLAY:
		peers = 1
		
	network = NetworkedMultiplayerENet.new()
	var ok = network.create_server(DEFAULT_PORT, peers)
	if ok == OK:
		get_tree().set_network_peer(network)
		print("Server started")
	else:
		print("Server could not be started")
		MessageManager.notify("Error: The server could not be started")

func connectToServer():
	network = NetworkedMultiplayerENet.new()
	
	var errorStatus = network.create_client(ip, DEFAULT_PORT)
	print("Trying to connect results in code #" + str(errorStatus))
	get_tree().set_network_peer(network)
	
func closeServer():
	network.close_connection()
	online = false
	host = false
	playerIDs.clear()
	playerNames.clear()
	
####################################################################

func _OnConnectFailed():
	print("failed to connect to server")
	
	if Settings.gameMode == Settings.GAME_MODE.LOBBY_DRAFT:
		MessageManager.notify("Error: Connection failed")
		get_node("/root/DraftLobby").backButtonPressed()
	
func _OnConnectSucceeded():
	print("connected to server")

func _Server_Disconnected():
	print("Server diconnected")
	closeServer()
	
	MessageManager.notify("Server disconnected")
	
	if Settings.gameMode == Settings.GAME_MODE.LOBBY_DRAFT:
		get_node("/root/DraftLobby").lobbyBackPressed()
	elif Settings.gameMode == Settings.GAME_MODE.DRAFTING:
		get_node("/root/Draft").closeDraft()
	elif Settings.gameMode == Settings.GAME_MODE.LOBBY_PLAY:
		get_node("/root/Lobby").disconnected()
	
####################################################################

func getPlayerData(player_id : int):
	rpc_id(player_id, "receiveGetPlayerData")

remote func receiveGetPlayerData():
	print("Fetching player data")
	rpc_id(get_tree().get_rpc_sender_id(), "receiveSetPlayerData", username, Settings.gameMode, Settings.versionID)

remote func receiveSetPlayerData(username : String, gameMode : int, versionID : String):
	print("Player data received")
	var player_id = get_tree().get_rpc_sender_id()
	
	if Settings.compareVersion(versionID, Settings.versionID) != 0:
		print("User attempted to connect with wrong version")
		rpc_id(player_id, "sendMessage", "Notice: Your game versions are not the same; Consider updating")
		network.disconnect_peer(player_id)
		return
	if gameMode != Settings.gameMode:
		print("User attempted to connect with wrong game mode")
		rpc_id(player_id, "sendMessage", "Notice: Wrong game modes")
		network.disconnect_peer(player_id)
		return
		
	
	for id in playerIDs:
		rpc_id(id, "addUser", player_id, username)
		rpc_id(player_id, "addUser", id, playerNames[id])
	addUser(player_id, username)
	rpc_id(player_id, "addUser", 1, self.username)
	rpc_id(player_id, "receiveConfirmJoin")
		
	if Settings.gameMode == Settings.GAME_MODE.LOBBY_PLAY:
		Settings.gameMode = Settings.GAME_MODE.PLAY
		get_node("/root/Lobby").startGame()
		rpc_id(player_id, "serverSetUsername", username)
	else:
		rpc_id(player_id, "joinedDraftLobby", Server.MAX_PEERS + 1)

remote func receiveConfirmJoin():
	print("Successfully joined the server")
	
	if Settings.gameMode == Settings.GAME_MODE.LOBBY_PLAY:
		Settings.gameMode = Settings.GAME_MODE.PLAY
		get_node("/root/Lobby").startGame()
		rpc_id(get_tree().get_rpc_sender_id(), "serverSetUsername", username)

func playerConnected(player_id : int):
	if Server.host:
		if Settings.gameMode == Settings.GAME_MODE.LOBBY_PLAY or Settings.gameMode == Settings.GAME_MODE.LOBBY_DRAFT:
			getPlayerData(player_id)
		else:
			rpc_id(player_id, "sendMessage", "Notice: The game has already begun")
			network.disconnect_peer(player_id)
		
func playerDisconnected(player_id : int):
	if Server.host:
		removeUser(player_id)
		for id in playerIDs:
			rpc_id(id, "removeUser", player_id)
			

####################################################################

remote func addUser(player_id : int, username : String):
	print("User "+ str(player_id) + " Connected")
	playerIDs.append(player_id)
	playerNames[player_id] = username
	if Settings.gameMode == Settings.GAME_MODE.LOBBY_DRAFT:
		get_node("/root/DraftLobby").addPlayer(player_id, username)
	elif Settings.gameMode == Settings.GAME_MODE.LOBBY_PLAY:
		pass

remote func removeUser(player_id : int):
	if Settings.gameMode == Settings.GAME_MODE.DRAFTING:
		get_node("/root/Draft").playerDisconnected(player_id)
	
	if Settings.gameMode == Settings.GAME_MODE.LOBBY_DRAFT:
		get_node("/root/DraftLobby").removePlayer(player_id)
	
	if playerIDs.has(player_id):
		print("User "+ str(player_id) + " Disconnected")
		MessageManager.notify("User "+ str(player_id) + " Disconnected")
	playerIDs.erase(player_id)
	playerNames.erase(player_id)
	
	if Settings.gameMode == Settings.GAME_MODE.PLAY:
		if playerIDs.size() == 0:
			get_node("/root/main/Board").gameOver = true
#			closeServer()

remote func kickUser(player_id):
	rpc_id(player_id, "sendMessage", "You have been kicked from the server")
	network.disconnect_peer(player_id)

remote func sendMessage(message : String):
	MessageManager.notify(message)

#func _input(event):
#	if event is InputEventKey and event.is_pressed() and not event.is_echo() and event.scancode == KEY_DELETE:
#		for id in playerIDs:
#			rpc_id(id, "sendMessage", "Testing")

####################################################################

remote func startDraft(index : int):
	if Server.host:
		for id in Server.playerIDs:
			Server.rpc_id(id, "startDraft", index)
	
	Settings.gameMode = Settings.GAME_MODE.DRAFTING
	var error = get_tree().change_scene(DraftLobby.getDraftTypes()[index][1])
	#var error = get_tree().change_scene("res://Scenes/DraftWinston.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))

remote func joinedDraftLobby(numMaxPlayers):
	get_node("/root/DraftLobby").joinedLobby(numMaxPlayers)

func sendDraftData(data : Array):
	for id in playerIDs:
		rpc_id(id, "receiveDraftData", data)

remote func receiveDraftData(data : Array):
	get_node("/root/Draft").setDraftData(data)

func addCardToStack(index):
	for id in playerIDs:
		rpc_id(id, "receiveAddCardToStack", index)

remote func receiveAddCardToStack(index):
	get_node("/root/Draft").addCardToStack(index, true)

func popMainStack():
	for id in playerIDs:
		rpc_id(id, "receivePopMainStack")

remote func receivePopMainStack():
	get_node("/root/Draft").mainStack.pop_front()

func startPick(player_id : int):
	rpc_id(player_id, "receiveStartPick")

remote func receiveStartPick():
	get_node("/root/Draft").startPick()

func clearStack(index : int):
	for id in playerIDs:
		rpc_id(id, "receiveClearStack", index)

remote func receiveClearStack(index : int):
	get_node("/root/Draft").clearStack(index, true)

func nextPlayer():
	rpc_id(1, "receiveNextPlayer")

remote func receiveNextPlayer():
	get_node("/root/Draft").nextPlayer()

func startBuilding():
	for id in playerIDs:
		rpc_id(id, "receivedStartBuilding")
	receivedStartBuilding()

remote func receivedStartBuilding():
	
	var root = get_node("/root")
	var draft = root.get_node("Draft")
	
	var availableCardCount : Dictionary
	
	for cardNode in draft.get_node("CardDisplay").nodes:
		if availableCardCount.has(cardNode.card.UUID):
			availableCardCount[cardNode.card.UUID] += 1
		else:
			availableCardCount[cardNode.card.UUID] = 1

	var editor = load("res://Scenes/DeckEditor.tscn").instance()
	editor.availableCardCount = availableCardCount
	root.add_child(editor)
	get_tree().current_scene = editor
	
	root.remove_child(draft)
	draft.queue_free()
	
	Settings.gameMode = Settings.GAME_MODE.NONE
	closeServer()

func setCurrentPlayerDisplay(currentPlayer):
	for id in playerIDs:
		rpc_id(id, "receiveSetCurrentPlayerDisplay", currentPlayer)

remote func receiveSetCurrentPlayerDisplay(currentPlayer):
	get_node("/root/Draft").setCurrentPlayerDisplay(currentPlayer)

#######################################################################################

func sendBooster(player_id : int, boosterData : Array):
	if player_id == get_tree().get_network_unique_id():
		receiveSendBooster(boosterData)
	else:
		rpc_id(player_id, "receiveSendBooster", boosterData)

remote func receiveSendBooster(boosterData : Array):
	get_node("/root/Draft").boosterQueue.append(boosterData)

func doneBoosterDraft():
	rpc_id(1, "receiveDoneBoosterDraft")

remote func receiveDoneBoosterDraft():
	get_node("/root/Draft").playerDoneDrafting(get_tree().get_rpc_sender_id())

func sendAllBoosters(player_id : int, boostersData : Array):
	rpc_id(player_id, "receiveSendAllBoosters", boostersData)

remote func receiveSendAllBoosters(boostersData : Array):
	get_node("/root/Draft").boosterQueue += boostersData





remote func serverSetUsername(username : String):
	var board = get_node_or_null("/root/main/Board")
	while not is_instance_valid(board) or board.gameStarted:
		print("Board not ready yet, waiting; fetch")
		yield(get_tree().create_timer(0.1), "timeout")
		board = get_node_or_null("/root/main/Board")
		if not Server.online:
			return
			
	board.setOpponentUsername(username)

remote func fetchDeck(player_id : int):
	if playerIDs.has(player_id):
		rpc_id(player_id, "serverFetchDeck")
	
remote func serverFetchDeck():
	var player_id = get_tree().get_rpc_sender_id()
	
	var board = get_node_or_null("/root/main/Board")
	while not is_instance_valid(board) or board.gameStarted:
		print("Board not ready yet, waiting; fetch")
		yield(get_tree().create_timer(0.1), "timeout")
		board = get_node_or_null("/root/main/Board")
		if not Server.online:
			return
			
	var data = board.players[0].deck.getJSONData()
	var order = board.players[0].deck.serialize()
		
	rpc_id(player_id, "returnDeck", data, order)

remote func returnDeck(data, order):
	get_node("/root/main/Board").setDeckData(data, order)

####################################################################

remote func onGameStart(player_id : int):
	if playerIDs.has(player_id):
		rpc_id(player_id, "serverOnGameStart")
	
remote func serverOnGameStart():
	var player_id = get_tree().get_rpc_sender_id()
	
	var board = get_node_or_null("/root/main/Board")
	board.onGameStart()

####################################################################

remote func slotClicked(player_id : int, isOpponent : bool, slotZone : int, slotID : int, button_index : int):
	if playerIDs.has(player_id):
		rpc_id(player_id, "serverSlotClicked", isOpponent, slotZone, slotID, button_index)
	
remote func serverSlotClicked(isOpponent : bool, slotZone : int, slotID : int, button_index : int):
	var player_id = get_tree().get_rpc_sender_id()
	
	var board = get_node_or_null("/root/main/Board")
	if board.activePlayer == 0 and Settings.gameMode == Settings.GAME_MODE.PLAY:
		return
	board.slotClickedServer(isOpponent, slotZone, slotID, button_index)
	
####################################################################

remote func onNextTurn(player_id : int):
	if playerIDs.has(player_id):
		rpc_id(player_id, "serverOnNextTurn")
	
remote func serverOnNextTurn():
	var player_id = get_tree().get_rpc_sender_id()
	
	var board = get_node_or_null("/root/main/Board")
	if board.activePlayer == 0 and Settings.gameMode == Settings.GAME_MODE.PLAY:
		return
	board.nextTurn()

####################################################################

remote func onRestart(player_id : int):
	if playerIDs.has(player_id):
		rpc_id(player_id, "serverOnRestart")
	
remote func serverOnRestart():
	var player_id = get_tree().get_rpc_sender_id()
	
	var board = get_node_or_null("/root/main/Board")
	board.onRestartPressed()
		

####################################################################

remote func setActivePlayer(player_id : int, index : int):
	if playerIDs.has(player_id):
		rpc_id(player_id, "serverSetActivePlayer", index)
	
remote func serverSetActivePlayer(index : int):
	var player_id = get_tree().get_rpc_sender_id()
	
	var board = get_node_or_null("/root/main/Board")
	while not is_instance_valid(board) or board.gameStarted:
		print("Board not ready yet, waiting; active")
		yield(get_tree().create_timer(0.1), "timeout")
		board = get_node_or_null("/root/main/Board")
		if not Server.online:
			return
#		if otherPlayerData != null and player_id != otherPlayerData:
#			return
	board.setStartingPlayer(index)

####################################################################

remote func disconnectMessage(player_id : int, message : String):
	if playerIDs.has(player_id):
		rpc_id(player_id, "serverDisconnectMessage", message)
	
remote func serverDisconnectMessage(message : String):
	Server.closeServer()
	Server.online = false
	Server.host = false
	
	MessageManager.notify(message)
	
	var error = get_tree().change_scene("res://Scenes/StartupScreen.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))

####################################################################

remote func fetchVersion(player_id : int):
	if playerIDs.has(player_id):
		rpc_id(player_id, "serverFetchVersion")
	
remote func serverFetchVersion():
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "returnVersion", Settings.versionID)

remote func returnVersion(version):
	get_node("/root/main/Board").compareVersion(version)
		
