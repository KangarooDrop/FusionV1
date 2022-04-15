extends Node2D

var username := "NO_NAME"

var host = false
var online = false
var ip = "127.0.0.1"

var network : NetworkedMultiplayerENet
const DEFAULT_PORT := 25565
var MAX_PEERS := 5

var opponentID = -1
var GM = false
var gmSet = false

var playerIDs := []
var playerNames := {}
var playersReady := {}

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
	
	if Server.host:
		playersReady[1] = false

func connectToServer():
	network = NetworkedMultiplayerENet.new()
	
	var errorStatus = network.create_client(ip, DEFAULT_PORT)
	print("Trying to connect results in code #" + str(errorStatus))
	get_tree().set_network_peer(network)
	
func closeServer():
	print("Terminating connection")
	network.close_connection()
	online = false
	host = false
	opponentID = -1
	playerIDs.clear()
	playerNames.clear()
	playersReady.clear()
	gmData.clear()
	
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
		rpc_id(player_id, "receiveSendMessage", "Notice: Your game versions are not the same; Consider updating")
		network.disconnect_peer(player_id)
		return
	if gameMode != Settings.gameMode:
		print("User attempted to connect with wrong game mode")
		rpc_id(player_id, "receiveSendMessage", "Notice: Wrong game modes")
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
		rpc_id(player_id, "serverSetUsername", self.username)
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
			rpc_id(player_id, "receiveSendMessage", "Notice: The game has already begun")
			network.disconnect_peer(player_id)
		
func playerDisconnected(player_id : int):
	if Server.host:
		removeUser(player_id)
		for id in playerIDs:
			rpc_id(id, "removeUser", player_id)
			

####################################################################

remote func setPlayerName(username : String):
	self.username = username
	if NodeLoc.getBoard() != null:
		NodeLoc.getBoard().editOwnName(username)
	if online:
		for id in playerIDs:
			rpc_id(id, "receiveSetPlayerName", username)

remote func receiveSetPlayerName(username : String, player_id : int = -1):
	if player_id == -1:
		player_id = get_tree().get_rpc_sender_id()
	playerNames[player_id] = username
	if NodeLoc.getBoard() != null:
		NodeLoc.getBoard().editPlayerName(player_id, username)

remote func addUser(player_id : int, username : String):
	print("User "+ str(player_id) + " Connected")
	playerIDs.append(player_id)
	playerNames[player_id] = username
	playersReady[player_id] = false
	if Settings.gameMode == Settings.GAME_MODE.LOBBY_DRAFT:
		get_node("/root/DraftLobby").addPlayer(player_id, username)
	elif Settings.gameMode == Settings.GAME_MODE.LOBBY_PLAY:
		pass

remote func removeUser(player_id : int):
	if playerIDs.has(player_id):
		print("User ", playerNames[player_id], "[", str(player_id), "] Disconnected")
		MessageManager.notify("User \"" + playerNames[player_id] + "\" Disconnected")
		if Settings.gameMode == Settings.GAME_MODE.TOURNAMENT:
			if opponentID == player_id:
				Server.setTournamentWinner(get_tree().get_network_unique_id())
#			Tournament.replaceWith(player_id, -1)
#			Tournament.trimBranches()
			if NodeLoc.getBoard() is TournamentLobby:
				NodeLoc.getBoard().checkNextGame()
	
	if Settings.gameMode == Settings.GAME_MODE.DRAFTING:
		get_node("/root/Draft").playerDisconnected(player_id)
	
	if Settings.gameMode == Settings.GAME_MODE.LOBBY_DRAFT:
		get_node("/root/DraftLobby").removePlayer(player_id)
	
	playerIDs.erase(player_id)
	#playerNames.erase(player_id)
	playersReady.erase(player_id)
	
	if Settings.gameMode == Settings.GAME_MODE.PLAY:
		if playerIDs.size() == 0:
			get_node("/root/main/CenterControl/Board").gameOver = true
#			closeServer()

remote func kickUser(player_id):
	rpc_id(player_id, "receiveSendMessage", "You have been kicked from the server")
	network.disconnect_peer(player_id)

func sendMessage(player_id, message : String):
	if playerIDs.has(player_id):
		rpc_id(player_id, "receiveSendMessage", message)

remote func receiveSendMessage(message : String):
	MessageManager.notify(message)

#func _input(event):
#	if event is InputEventKey and event.is_pressed() and not event.is_echo() and event.scancode == KEY_DELETE:
#		for id in playerIDs:
#			rpc_id(id, "sendMessage", "Testing")

####################################################################

func setDraftType(index : int):
	for id in Server.playerIDs:
		rpc_id(id, "receiveSetDraftType", index)

remote func receiveSetDraftType(index : int):
	get_node("/root/DraftLobby").draftTypeSelected(index)

remote func startDraft(index : int, params : Dictionary = {}):
	if Server.host:
		for id in Server.playerIDs:
			Server.rpc_id(id, "startDraft", index, params)
	
	Settings.gameMode = Settings.GAME_MODE.DRAFTING
	
	var root = get_node("/root")
	var lobby = root.get_node("DraftLobby")
	var draft = load(DraftLobby.getDraftTypes()[index][1]).instance()
	
	draft.setParams(params)
	root.add_child(draft)
	get_tree().current_scene = draft
	
	root.remove_child(lobby)
	lobby.queue_free()

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
	yield(get_tree().create_timer(1), "timeout")
	receivedStartBuilding()

remote func receivedStartBuilding():
	
	print("Starting draft deck build")
	
	var root = get_node("/root")
	var draft = root.get_node("Draft")
	
	var availableCardCount : Dictionary
	
	for cardNode in draft.get_node("CardDisplay").nodes:
		if availableCardCount.has(cardNode.card.UUID):
			availableCardCount[cardNode.card.UUID] += 1
		else:
			availableCardCount[cardNode.card.UUID] = 1
	var dd = draft.get_node_or_null("DeckDisplayControl/DeckDisplay")
	if dd != null:
		for d in dd.data:
			if availableCardCount.has(d.card.UUID):
				availableCardCount[d.card.UUID] += d.count
			else:
				availableCardCount[d.card.UUID] = d.count

	var editor = load("res://Scenes/DeckEditor.tscn").instance()
	editor.availableCardCount = availableCardCount
	root.add_child(editor)
	get_tree().current_scene = editor
	
	root.remove_child(draft)
	draft.queue_free()
	
	Settings.gameMode = Settings.GAME_MODE.NONE
	#closeServer()

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
	if get_node_or_null("/root/Draft") != null:
		get_node("/root/Draft").boosterQueue.append(boosterData)

func doneBoosterDraft():
	rpc_id(1, "receiveDoneBoosterDraft")

remote func receiveDoneBoosterDraft():
	get_node("/root/Draft").playerDoneDrafting(get_tree().get_rpc_sender_id())

func sendAllBoosters(player_id : int, boostersData : Array):
	rpc_id(player_id, "receiveSendAllBoosters", boostersData)

remote func receiveSendAllBoosters(boostersData : Array):
	if get_node_or_null("/root/Draft") != null:
		get_node("/root/Draft").boosterQueue += boostersData





remote func serverSetUsername(username : String):
	var board = get_node_or_null("/root/main/CenterControl/Board")
	while not is_instance_valid(board) or board.gameStarted or board.playerRestart:
		print("Board not ready yet, waiting; active")
		yield(get_tree().create_timer(0.1), "timeout")
		board = get_node_or_null("/root/main/CenterControl/Board")
		if not Server.online:
			return
	board.setOpponentUsername(username)

remote func sendDeck(player_id : int):
	if playerIDs.has(player_id):
		var board = get_node("/root/main/CenterControl/Board")
		var data = board.players[0].deck.getJSONData()
		var order = board.players[0].deck.serialize()
		rpc_id(player_id, "serverSendDeck", data, order)

remote func serverSendDeck(data, order):
	var board = get_node_or_null("/root/main/CenterControl/Board")
	while not is_instance_valid(board) or board.gameStarted or board.playerRestart:
		print("Board not ready yet, waiting; active")
		yield(get_tree().create_timer(0.1), "timeout")
		board = get_node_or_null("/root/main/CenterControl/Board")
		if not Server.online:
			return
	board.setDeckData(data, order)

####################################################################

remote func onGameStart(player_id : int):
	if playerIDs.has(player_id):
		rpc_id(player_id, "serverOnGameStart")
	
remote func serverOnGameStart():
	var player_id = get_tree().get_rpc_sender_id()
	print("Received game start signal from ", player_id)
	
	var board = get_node_or_null("/root/main/CenterControl/Board")
	while not is_instance_valid(board) or not board is BoardMP or board.gameStarted or board.playerRestart:
		print("Board not ready yet, waiting; active")
		yield(get_tree().create_timer(0.1), "timeout")
		board = get_node_or_null("/root/main/CenterControl/Board")
		if not Server.online:
			return
	board.onGameStart()

####################################################################

remote func slotClicked(player_id : int, isOpponent : bool, slotZone : int, slotID : int, button_index : int):
	if playerIDs.has(player_id):
		rpc_id(player_id, "serverSlotClicked", isOpponent, slotZone, slotID, button_index)
	
remote func serverSlotClicked(isOpponent : bool, slotZone : int, slotID : int, button_index : int):
	var player_id = get_tree().get_rpc_sender_id()
	
	var board = get_node_or_null("/root/main/CenterControl/Board")
	#if board.activePlayer == 0 and Settings.gameMode == Settings.GAME_MODE.PLAY:
	#	return
	board.slotClickedServer(isOpponent, slotZone, slotID, button_index)
	
####################################################################

remote func onNextTurn(player_id : int):
	if playerIDs.has(player_id):
		rpc_id(player_id, "serverOnNextTurn")
	
remote func serverOnNextTurn():
	var player_id = get_tree().get_rpc_sender_id()
	
	var board = get_node_or_null("/root/main/CenterControl/Board")
	if board.activePlayer == 0 and Settings.gameMode == Settings.GAME_MODE.PLAY:
		return
	board.nextTurn()

####################################################################

remote func onRestart(player_id : int):
	if playerIDs.has(player_id):
		rpc_id(player_id, "serverOnRestart")
	
remote func serverOnRestart():
	var player_id = get_tree().get_rpc_sender_id()
	
	var board = get_node_or_null("/root/main/CenterControl/Board")
	board.onRestartPressed()
		

####################################################################

#func waitForBoard():
#	var board = get_node_or_null("/root/main/CenterControl/Board")
#	while not is_instance_valid(board) or board.gameStarted or board.playerRestart:
#		print("Board not ready yet, waiting; active")
#		yield(get_tree().create_timer(0.1), "timeout")
#		board = get_node_or_null("/root/main/CenterControl/Board")
#		if not Server.online:
#			return

remote func setActivePlayer(player_id : int, index : int):
	if playerIDs.has(player_id):
		rpc_id(player_id, "serverSetActivePlayer", index)
	
remote func serverSetActivePlayer(index : int):
	var player_id = get_tree().get_rpc_sender_id()
	var board = get_node_or_null("/root/main/CenterControl/Board")
	while not is_instance_valid(board) or board.gameStarted or board.playerRestart:
		print("Board not ready yet, waiting; active")
		yield(get_tree().create_timer(0.1), "timeout")
		board = get_node_or_null("/root/main/CenterControl/Board")
		if not Server.online:
			return
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

func setGameSeed(player_id : int, gameSeed : int):
	print("Sending seed to opponent: ", gameSeed)
	if playerIDs.has(player_id):
		rpc_id(player_id, "receiveSetGameSeed", gameSeed)

remote func receiveSetGameSeed(gameSeed):
	var board = get_node_or_null("/root/main/CenterControl/Board")
	while not is_instance_valid(board) or board.gameStarted or board.playerRestart:
		print("Board not ready yet, waiting; active")
		yield(get_tree().create_timer(0.1), "timeout")
		board = get_node_or_null("/root/main/CenterControl/Board")
		if not Server.online:
			return
	board.setGameSeed(gameSeed)

func mulliganDone(player_id : int):
	if playerIDs.has(player_id):
		rpc_id(player_id, "receiveMulliganDone")

remote func receiveMulliganDone():
	var board = get_node_or_null("/root/main/CenterControl/Board")
	while not is_instance_valid(board) or board.gameStarted or board.playerRestart:
		print("Board not ready yet, waiting; active")
		yield(get_tree().create_timer(0.1), "timeout")
		board = get_node_or_null("/root/main/CenterControl/Board")
		if not Server.online:
			return
	board.mulliganOpponentDone()

func requestMulligan(player_id : int):
	if playerIDs.has(player_id):
		rpc_id(player_id, "receiveRequestMulligan")
	
remote func receiveRequestMulligan():
	var board = get_node_or_null("/root/main/CenterControl/Board")
	while not is_instance_valid(board) or board.gameStarted or board.playerRestart:
		print("Board not ready yet, waiting; active")
		yield(get_tree().create_timer(0.1), "timeout")
		board = get_node_or_null("/root/main/CenterControl/Board")
		if not Server.online:
			return
	board.mulliganOpponent()

func sendMulliganDeck(player_id : int):
	if playerIDs.has(player_id):
		var board = get_node("/root/main/CenterControl/Board")
		var order = board.players[1].deck.serialize()
		rpc_id(player_id, "receiveSendMulliganDeck", order)

remote func receiveSendMulliganDeck(order : Array):
	var cards := []
	for c in order:
		cards.append(ListOfCards.getCard(c))
		
	var board = get_node_or_null("/root/main/CenterControl/Board")
	while not is_instance_valid(board) or board.gameStarted or board.playerRestart:
		print("Board not ready yet, waiting; active")
		yield(get_tree().create_timer(0.1), "timeout")
		board = get_node_or_null("/root/main/CenterControl/Board")
		if not Server.online:
			return
			
	board.players[0].deck.setCards(cards, board.players[0].UUID)
	board.players[0].hand.drawHand()
	board.mulliganDone = true
	board.handMoving = true

####################################################################

func sendSolomonCards(player_id : int, cards : Array, withFlourish = false):
	if playerIDs.has(player_id):
		rpc_id(player_id, "receiveSendSolomonCards", cards, withFlourish)

remote func receiveSendSolomonCards(cards : Array, withFlourish = false):
	get_node("/root/Draft").setCards(cards, withFlourish)

func takeSolomonStack(player_id : int, stackNum : int):
	if playerIDs.has(player_id):
		rpc_id(player_id, "receiveTakeSolomonStack", stackNum)

remote func receiveTakeSolomonStack(stackNum):
	get_node("/root/Draft").takeSolomonStack(stackNum)

func doneSplitting(player_id : int):
	if playerIDs.has(player_id):
		rpc_id(player_id, "receiveDoneSplitting")

remote func receiveDoneSplitting():
	get_node("/root/Draft").opponentDoneSplitting()

func solomonSlotClicked(player_id : int, cardDisplayInt : int, cardIndex : int):
	if playerIDs.has(player_id):
		rpc_id(player_id, "receiveSolomonSlotClicked", cardDisplayInt, cardIndex)

remote func receiveSolomonSlotClicked(cardDisplayInt : int, cardIndex : int):
	get_node("/root/Draft").opponentSlotClicked(cardDisplayInt, cardIndex)

func solomonStart(player_id : int):
	if playerIDs.has(player_id):
		rpc_id(player_id, "receiveSolomonStart")
		
remote func receiveSolomonStart():
	get_node("/root/Draft").genNewBooster()

func solomonSetState(player_id : int, state : int):
	if playerIDs.has(player_id):
		rpc_id(player_id, "receiveSolomonSetState", state)
		
remote func receiveSolomonSetState(state : int):
	get_node("/root/Draft").setOpponentState(state)

func startSolomonBuilding(player_id):
	rpc_id(player_id, "receivedStartBuilding")
	receivedStartBuilding()

####################################################################

func setReady(ready : bool):
	if Server.online:
		if Server.host:
			playersReady[1] = ready
			checkReady()
		else:
			rpc_id(1, "receiveSetReady", ready)
	else:
		print("The Server is currently offline")

remote func receiveSetReady(ready : bool):
	var player_id = get_tree().get_rpc_sender_id()
	playersReady[player_id] = ready
	checkReady()
	
func checkReady():
	for player_id in playersReady.keys():
		if not playersReady[player_id]:
			return
	
	var bracket = Tournament.genTournamentOrder(playersReady.keys())
	receiveSetBracket(bracket)
	for player_id in playerIDs:
		rpc_id(player_id, "receiveSetBracket", bracket)

remote func receiveSetBracket(bracket):
	Tournament.startTournament(bracket)
	Tournament.trimBranches()
	print("TOURNAMENT = ", Tournament.tree)
	
	var error = get_tree().change_scene("res://Scenes/Networking/TournamentLobby.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))

func onConcede(player_id):
	if playerIDs.has(player_id):
		rpc_id(player_id, "receiveOnConcede")

remote func receiveOnConcede():
	var board = NodeLoc.getBoard()
	board.playerRestart = true
	board.opponentRestart = true
	Tournament.addWin()

func setTournamentWinner(player_id):
	receiveSetTournamentWinner(player_id)
	for p in playerIDs:
		rpc_id(p, "receiveSetTournamentWinner", player_id)

remote func receiveSetTournamentWinner(player_id):
	var onPlaying = false
	var selfID = get_tree().get_network_unique_id()
	if Tournament.getOpponent(player_id) == selfID or selfID == player_id:
		onPlaying = true
		gmSet = false
		GM = false
		Tournament.currentWins = 0
		Tournament.currentLosses = 0
		print("Clearing tournament game data")
		
	Tournament.setWinner(player_id)
	
	if NodeLoc.getBoard() is TournamentLobby:
		NodeLoc.getBoard().checkNextGame()
	
	if onPlaying:
		var error = get_tree().change_scene("res://Scenes/Networking/TournamentLobby.tscn")
		if error != 0:
			print("Error loading test1.tscn. Error Code = " + str(error))

func requestGM(p1, p2):
	if Server.host:
		receiveRequestGM(p1, p2)
	elif Server.online:
		rpc_id(1, "receiveRequestGM", p1, p2)

var gmData := {}
remote func receiveRequestGM(p1, p2):
	if not gmData.keys().has([p1, p2]) and not gmData.keys().has([p2, p1]):
		var gm
		if randi() % 2 == 0:
			gm = p1
		else:
			gm = p2
		gmData[[p1, p2]] = gm
		
		if Server.host and p1 == 1:
			receiveSetGM(gm == p1)
		else:
			rpc_id(p1, "receiveSetGM", gm == p1)
		
		if Server.host and p2 == 1:
			receiveSetGM(gm == p2)
		else:
			rpc_id(p2, "receiveSetGM", gm == p2)

remote func receiveSetGM(isGM):
	GM = isGM
	gmSet = true
	print("Received the GM set command")

####################################################################

remote func fetchVersion(player_id : int):
	if playerIDs.has(player_id):
		rpc_id(player_id, "serverFetchVersion")
	
remote func serverFetchVersion():
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "returnVersion", Settings.versionID)

remote func returnVersion(version):
	var board = get_node_or_null("/root/main/CenterControl/Board")
	while not is_instance_valid(board) or board.gameStarted or board.playerRestart:
		print("Board not ready yet, waiting; active")
		yield(get_tree().create_timer(0.1), "timeout")
		board = get_node_or_null("/root/main/CenterControl/Board")
		if not Server.online:
			return
	board.compareVersion(version)

