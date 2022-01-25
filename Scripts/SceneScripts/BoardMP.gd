
extends Node2D

class_name BoardMP

var cardSlot = preload("res://Scenes/CardSlot.tscn")
var cardNode = preload("res://Scenes/CardNode.tscn")
onready var cardWidth = ListOfCards.cardBackground.get_width()
onready var cardHeight = ListOfCards.cardBackground.get_height()
var hoverScene = preload("res://Scenes/UI/Hover.tscn")
var fadingScene = preload("res://Scenes/UI/FadingNode.tscn")

var cardDists = 16

var creatures : Dictionary
var decks : Dictionary

var boardSlots : Array

var players : Array
var activePlayer := -1
var cardsPerTurn = 2#99
var cardsPlayed = 0

var shakeMaxTime = 0.5
var shakeAmount = 0.8
var shakeFrequency = 6
var cardsShaking := {}

onready var creatures_A_Holder = $Creatures_A
onready var creatures_B_Holder = $Creatures_B
onready var deckHolder = $DeckHolder
onready var card_A_Holder = $Card_A_Holder
onready var card_B_Holder = $Card_B_Holder

var cardsHolding : Array
var selectedCard : CardSlot
var selectRotTimer = 0

var actionQueue : Array

var millQueue : Array
var millNode
var millWaitTimer = 0
var millWaitMaxTime = 0.5

var isEntering = false
var fuseQueue : Array
var fusing = false
var fuseEndSlot = null
var fuseEndPos = null
var fuseStartPos = null
var fuseTimer = 0
var fuseMaxTime = 0.1
var fuseReturnTimer = 0
var fuseReturnMaxTime = 0.3
var fuseWaiting = false
var fuseWaitTimer = 0
var fuseWaitMaxTime = 0.3

var gameStarted = false
var gameOver = false

enum GAME_MODE {PLAYING, SPECTATE, REPLAY}
var settingSpectateData = false

func _ready():
	var gameSeed = OS.get_system_time_msecs()
	print("current game seed is ", gameSeed)
	seed(gameSeed)
	
	if Settings.gameMode == GAME_MODE.PLAYING:
		var cardList = getDeckFromFile()
		cardList.shuffle()
		setOwnCardList(cardList)
		
		if Server.online and Server.host:
			var startingPlayerIndex = randi() % 2
			activePlayer = (startingPlayerIndex + 1) % 2
			print("Send: Starting player")
			dataLog.append("SET_PLAYER " + str((startingPlayerIndex + 1) % 2))
			Server.setActivePlayer(startingPlayerIndex)
			hasStartingPlayer = true
	
		print("Fetch: Opponent's deck list")
		Server.fetchDeck(get_instance_id())
		Server.fetchVersion(get_instance_id())
		
	elif Settings.gameMode == GAME_MODE.REPLAY:
		dataLog = FileIO.getDataLog(Settings.dumpPath + Settings.dumpFile)
		
	elif Settings.gameMode == GAME_MODE.SPECTATE:
		print("SPECTATING STARTED")

func getDeckFromFile() -> Array:
	var fileName = Settings.selectedDeck
	var path = Settings.path
	
	var dataRead = FileIO.readJSON(path + fileName)
	var error = Deck.verifyDeck(dataRead)
	var cardList := []
	
	if error == Deck.DECK_VALIDITY_TYPE.VALID:
		for k in dataRead.keys():
			var id = int(k)
			for i in range(int(dataRead[k])):
				cardList.append(ListOfCards.getCard(id))
	else:
		MessageManager.notify("Invalid Deck:\nverify deck file contents")
		Server.disconnectMessage("Error: Opponent's deck is invalid")
		print("INVALID DECK : ", error, " : ", Deck.DECK_VALIDITY_TYPE.keys()[error])
	
		var sceneError = get_tree().change_scene("res://Scenes/StartupScreen.tscn")
		if sceneError != 0:
			print("Error loading test1.tscn. Error Code = " + str(sceneError))
			
	return cardList

func setOwnCardList(cardList : Array):
	var player_A = Player.new(cardList, self, $HealthNode)
	players.insert(0, player_A)
	creatures[player_A.UUID] = []
	
	var logDeck = "OWN_DECK "
	for i in player_A.deck.serialize():
		logDeck += str(i) + " "
		
	if Settings.gameMode == GAME_MODE.PLAYING:
		dataLog.append(logDeck)

var deckDataSet = false
var readyToStart = false
var hasStartingPlayer = false
var versionConfirmed = false

func setOpponentCardList(cardList : Array):
	var cards = []
	for id in cardList:
		cards.append(ListOfCards.getCard(id))
				
	var player_B = Player.new(cards, self, $HealthNode2)
	player_B.isOpponent = true
	players.insert(1, player_B)
	creatures[player_B.UUID] = []
	
	var logDeck = "OPPONENT_DECK "
	for i in players[1].deck.serialize():
		logDeck += str(i) + " "
		
	if Settings.gameMode == GAME_MODE.PLAYING:
		dataLog.append(logDeck)

func setDeckData(data, order):
	print("Receive: Opponent deck data")
	
	var good = verifyDeckData(data, order)
	if good:
		setOpponentCardList(order)
	else:
		MessageManager.notify("Opponent's deck is invalid")
		Server.disconnectMessage("Error: Your deck has been flagged by the opponent as invalid")
		print("INVALID DECK OPPONENT")
	
		var sceneError = get_tree().change_scene("res://Scenes/StartupScreen.tscn")
		if sceneError != 0:
			print("Error loading test1.tscn. Error Code = " + str(sceneError))
	
	print("Send: Game start signal")
	Server.onGameStart()
	deckDataSet = true

func verifyDeckData(data, order) -> bool:
	var error = Deck.verifyDeck(data)
	if error == Deck.DECK_VALIDITY_TYPE.VALID:
		
		var dict = {}
		for id in order:
			if not dict.has(str(id)):
				dict[str(id)] = 0
			dict[str(id)] += 1
		for k in dict.keys():
			dict[k] = float(dict[k])
			
		var dictKeys = dict.keys()
		var dataKeys = data.keys()
		for k in data.keys():
			if dictKeys.has(k):
				dictKeys.erase(k)
			else:
				return false
		for k in dict.keys():
			if dataKeys.has(k):
				dataKeys.erase(k)
			else:
				return false
		if dictKeys.size() > 0 or dataKeys.size() > 0:
			return false
			
		for k in data.keys():
			if data[k] != dict[k]:
				return false
			
		return true
	else:
		return false
			

func compareVersion(version):
	if Settings.gameMode == GAME_MODE.PLAYING:
		dataLog.append("VERSION " + version)
	var error = Settings.compareVersion(Settings.versionID, version)
	if error == 0:
		versionConfirmed = true
	else:
		MessageManager.notify("Error: Incompatable game versions")
		Server.disconnectMessage("Error: Incompatable game versions")
		print("INVALID VERSIONS")
	
		var sceneError = get_tree().change_scene("res://Scenes/StartupScreen.tscn")
		if sceneError != 0:
			print("Error loading test1.tscn. Error Code = " + str(sceneError))

func onGameStart():
	print("Receive: Ready to start")
	readyToStart = true

func setStartingPlayer(playerIndex : int):
	print("Receive: Starting player")
	if Settings.gameMode == GAME_MODE.PLAYING:
		dataLog.append("SET_PLAYER " + str(playerIndex))
	activePlayer = playerIndex
	hasStartingPlayer = true

var playerRestart = false
var opponentRestart = false
func onRestartPressed():
	if not playerRestart and not opponentRestart:
		MessageManager.notify("Opponent has requested to restart")
	opponentRestart = true

func startGame():
	initZones()
	initHands()
	
	readyToStart = false
	deckDataSet = false
	versionConfirmed = false
	hasStartingPlayer = false
	gameStarted = true
	players[0].initHand(self)
	players[1].initHand(self)
	print("Notice: Players ready, starting game")
	dataLog.append("GAME_START")
	
	if activePlayer == 0:
		$TurnIndicator.startTurn()

func _physics_process(delta):
	
	if Settings.gameMode == GAME_MODE.REPLAY and not replayWaiting and not gameOver:
		replayTimer += delta
		if replayTimer >= 0.3:
			nextReplayAction()
	
	if readyToStart and deckDataSet and hasStartingPlayer and versionConfirmed:
		startGame()
		
	if playerRestart and opponentRestart:
		if Server.host:
			Server.spectatorRestart()
		
		var error = get_tree().change_scene("res://Scenes/main.tscn")
		if error != 0:
			print("Error loading test1.tscn. Error Code = " + str(error))
		
		
	
		
	if is_instance_valid(selectedCard):
		selectRotTimer += delta
		selectedCard.cardNode.rotation = sin(selectRotTimer * 1.5) * PI / 32
	
	if fuseQueue.size() > 0:
		if fuseWaiting:
			fuseWaitTimer += delta
			if fuseWaitTimer >= fuseWaitMaxTime:
				fuseWaiting = false
		else:
			if fuseQueue.size() > 1:
				if not fusing:
					fusing = true
					fuseStartPos = fuseQueue[1].position
					fuseEndPos = fuseQueue[0].position
				if fusing:
					fuseTimer += delta
					if fuseTimer >= fuseMaxTime:
						fuseTimer = 0
						fusing = false
						fuseQueue[0].card = ListOfCards.fusePair(fuseQueue[0].card, fuseQueue[1].card)
						fuseQueue[0].setCardVisible(true)
						fuseQueue[1].queue_free()
						fuseQueue.remove(1)
						fuseWaiting = true
						fuseWaitTimer = 0
						if fuseQueue.size() == 1:
							fuseStartPos = fuseQueue[0].global_position
							fuseReturnTimer = 0
					else:
						fuseQueue[1].position = lerp(fuseStartPos, fuseEndPos, fuseTimer / fuseMaxTime)
			elif fuseQueue.size() == 1:
				fuseReturnTimer += delta
				fuseQueue[0].global_position = lerp(fuseStartPos, fuseEndSlot.global_position, fuseReturnTimer / fuseReturnMaxTime)
				if fuseReturnTimer >= fuseReturnMaxTime:
					var cardNode = fuseQueue[0]
					fuseEndSlot.cardNode = fuseQueue[0]
					cardNode.get_parent().remove_child(cardNode)
					cardNode.slot = fuseEndSlot
					creatures_A_Holder.add_child(cardNode)
					cardNode.global_position = fuseEndSlot.global_position
					fuseQueue = []
					cardNode.card.playerID = fuseEndSlot.playerID
					cardNode.card.cardNode = cardNode
					if isEntering:
						cardNode.card.onEnter(self, fuseEndSlot)
						for s in creatures[fuseEndSlot.playerID]:
							if is_instance_valid(s.cardNode) and s != fuseEndSlot:
								s.cardNode.card.onOtherEnter(self, fuseEndSlot)
					else:
						cardNode.card.onEnterFromFusion(self, fuseEndSlot)
						for s in creatures[fuseEndSlot.playerID]:
							if is_instance_valid(s.cardNode) and s != fuseEndSlot:
								s.cardNode.card.onOtherEnterFromFusion(self, fuseEndSlot)
					checkState()
					
	if millQueue.size() > 0:
		if millWaitTimer == 0:
			var playerNum = -1
			for i in range(players.size()):
				if players[i].UUID == millQueue[0]:
					playerNum = i
			
			var card
			if playerNum != -1:
				card = players[playerNum].deck.pop()
			else:
				millQueue.remove(0)
				print("Player ID not found for mill")
				
			if card != null:
				var cn = cardNode.instance()
				cn.card = card
				add_child(cn)
				cn.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
				cn.global_position = decks[players[playerNum].UUID].global_position
				var fn = fadingScene.instance()
				fn.maxTime = 1
				cn.add_child(fn)
				cn.get_node("FadingNode").setVisibility(1)
				millNode = cn
			else:
				millQueue.remove(0)
		
		if is_instance_valid(millNode):
			if millWaitTimer < millWaitMaxTime:
				millWaitTimer += delta
				if millWaitTimer >= millWaitMaxTime:
					millNode.get_node("FadingNode").fadeOut()
					millNode = null
					millQueue.remove(0)
					millWaitTimer = 0
				else:
					millNode.position.x -= cardWidth * Settings.cardSlotScale * 1.5 * delta / millWaitMaxTime
					
	for slot in cardsShaking.keys():
		if not is_instance_valid(slot.cardNode):
			cardsShaking.erase(slot)
		else:
			cardsShaking[slot] -= delta
			if cardsShaking[slot] < 0:
				slot.cardNode.global_position = slot.global_position
				cardsShaking.erase(slot)
			else:
				slot.cardNode.position.x += cos((shakeMaxTime - cardsShaking[slot]) * PI * 2 * shakeFrequency) * shakeAmount
				
	if serverQueue.size() > 0:
		serverCheckTimer += delta
		if serverCheckTimer >= serverCheckMaxTime:
			if slotClicked(serverQueue[0][0], serverQueue[0][1], serverQueue[0][2]):
				serverQueue.remove(0)
				serverWait = 0
				serverCheckTimer = serverCheckMaxTime
			else:
				serverCheckTimer = 0
			
		serverWait += delta
		if serverWait >= serverMaxWait:
			serverQueue.remove(0)
			serverWait = 0
			serverCheckTimer = 0
			
	if gameStarted:
		if actionQueue.size() > 0 and fuseQueue.size() == 0 and (not is_instance_valid(actionQueue[0][0].cardNode) or not actionQueue[0][0].cardNode.attacking):
			slotClicked(actionQueue[0][0], actionQueue[0][1], false)
			actionQueue.remove(0)

func nextReplayAction():
	replayWaiting = true
	var waiting = true
	while waiting and gameStarted:
		var attacking = false
		for slot in creatures[players[activePlayer].UUID]:
			if is_instance_valid(slot.cardNode) and slot.cardNode.attacking:
				attacking = true
		if not attacking:
			waiting = false
				
		for p in players:
			if p.hand.drawQueue.size() > 0:
				waiting = true
				
		if fuseQueue.size() > 0:
			waiting = true
				
		yield(get_tree().create_timer(0.1), "timeout")
	
	var nextCommand = dataLog[replayIndex]
	processReplayCommand(nextCommand)
	
	replayIndex += 1
	if replayIndex >= dataLog.size():
		gameOver = true
	replayWaiting = false
	replayTimer = 0
	
func processReplayCommand(command : String):
	var coms = command.split(" ")
	match coms[0]:
		"GAME_START":
			pass
#			if Settings.gameMode == GAME_MODE.SPECTATE:
#				startGame()
		"NEXT_TURN":
			nextTurn()
		"OWN_DECK":
			print("Notice: Setting own deck from replay")
			var cards = []
			for i in range(coms.size() - 1):
				cards.append(ListOfCards.getCard(int(coms[i+1])))
			setOwnCardList(cards)
			deckDataSet = true
		"OPPONENT_DECK":
			print("Notice: Setting opponent deck from replay")
			var cardsIDs = []
			for i in range(coms.size() - 1):
				cardsIDs.append(int(coms[i+1]))
			setOpponentCardList(cardsIDs)
			readyToStart = true
		"SET_PLAYER":
			print("Notice: Setting starting player from replay")
			setStartingPlayer(int(coms[1]))
		"OWN_SLOT":
			slotClickedServer(coms[1] != "True", int(coms[2]), int(coms[3]), 1)
		"OPPONENT_SLOT":
			slotClickedServer(coms[1] != "True", int(coms[2]), int(coms[3]), 1)
		"VERSION":
			compareVersion(coms[1])
		_:
			print("ERROR: Unknown replay command " + coms[0])
	

func createHoverNode(position : Vector2, text : String):
	var hoverInst = hoverScene.instance()
	add_child(hoverInst)
	hoverInst.global_position = position
	hoverInst.setText(text)
	hoveringWindow = hoverInst

func initZones():
	var cardInst = null
	
	#	PLAYER 1 SLOTS  	#
	var p = players[0]
	
	for i in range(p.creatureNum):
		cardInst = cardSlot.instance()
		cardInst.currentZone = CardSlot.ZONES.CREATURE
		cardInst.board = self
		cardInst.playerID = p.UUID
		creatures_A_Holder.add_child(cardInst)
		cardInst.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
		creatures[p.UUID].append(cardInst)
		boardSlots.append(cardInst)
	centerNodes(creatures[p.UUID], Vector2(), cardWidth, cardDists)
	
	cardInst = cardSlot.instance()
	cardInst.currentZone = CardSlot.ZONES.DECK
	cardInst.board = self
	cardInst.playerID = p.UUID
	deckHolder.add_child(cardInst)
	cardInst.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
	cardInst.position = Vector2(0, cardHeight + cardDists)
	var cardNodeInst = cardNode.instance()
	cardNodeInst.card = ListOfCards.getCard(0)
	cardNodeInst.cardVisible = false
	cardNodeInst.playerID = p.UUID
	deckHolder.add_child(cardNodeInst)
	cardNodeInst.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
	cardInst.cardNode = cardNodeInst
	cardNodeInst.position = cardInst.position
	decks[p.UUID] = cardInst
	
	
	#	PLAYER 2 SLOTS  	#
	p = players[1]
	
	for i in range(p.creatureNum):
		cardInst = cardSlot.instance()
		cardInst.isOpponent = true
		cardInst.currentZone = CardSlot.ZONES.CREATURE
		cardInst.board = self
		cardInst.playerID = p.UUID
		creatures_B_Holder.add_child(cardInst)
		cardInst.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
		creatures[p.UUID].append(cardInst)
		boardSlots.append(cardInst)
	centerNodes(creatures[p.UUID], Vector2(), cardWidth, cardDists)
	
	cardInst = cardSlot.instance()
	cardInst.currentZone = CardSlot.ZONES.DECK
	cardInst.isOpponent = true
	cardInst.board = self
	cardInst.playerID = p.UUID
	deckHolder.add_child(cardInst)
	cardInst.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
	cardInst.position = Vector2(0, -cardHeight - cardDists)
	cardNodeInst = cardNode.instance()
	cardNodeInst.card = ListOfCards.getCard(0)
	cardNodeInst.cardVisible = false
	cardNodeInst.playerID = p.UUID
	deckHolder.add_child(cardNodeInst)
	cardNodeInst.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
	cardInst.cardNode = cardNodeInst
	cardNodeInst.position = cardInst.position
	decks[p.UUID] = cardInst
	
		
func initHands():
	players[0].hand = card_A_Holder
	#players[0].initHand(self)
	players[1].hand = card_B_Holder
	#players[1].initHand(self)
	players[0].hand.deck = decks[players[0].UUID]
	players[1].hand.deck = decks[players[1].UUID]
	
	if activePlayer == 0:
		$CardsLeftIndicator_A.setCardData(cardsPerTurn, 0, 0)
		$CardsLeftIndicator_B.setCardData(0, 0, cardsPerTurn)
	else:
		$CardsLeftIndicator_A.setCardData(0, 0, cardsPerTurn)
		$CardsLeftIndicator_B.setCardData(cardsPerTurn, 0, 0)
				
static func centerNodes(nodes : Array, position : Vector2, cardWidth : int, cardDists : int):
	for i in range(nodes.size()):
		nodes[i].position = position + Vector2(-(nodes.size() - 1) / 2.0 * (cardWidth * Settings.cardSlotScale + cardDists) + (cardWidth * Settings.cardSlotScale + cardDists) * i, 0)
		
var serverQueue = []
var serverWait = 0
var serverMaxWait = 1
var serverCheckMaxTime = 0.1
var serverCheckTimer = serverCheckMaxTime

#F 1 8 1
func slotClickedServer(isOpponent : bool, slotZone : int, slotID : int, button_index : int):
	var playerIndex = 0 if isOpponent else 1
	var parent
	match slotZone:
		CardSlot.ZONES.NONE:
			parent = null
		CardSlot.ZONES.HAND:
			parent = players[playerIndex].hand
		CardSlot.ZONES.CREATURE:
			if playerIndex == 0:
				parent = creatures_A_Holder
			else:
				parent = creatures_B_Holder
		CardSlot.ZONES.DECK:
			parent = deckHolder
	#while settingSpectateData:
	#	yield(get_tree().create_timer(0.02), "timeout")
		
	if serverQueue.size() == 0:
		if not slotClicked(parent.get_child(slotID), button_index, true):
			serverQueue.append([parent.get_child(slotID), button_index, true])
			print("ERROR OCCURED FROM SERVER CLICK; SLOT NOT READY: QUEUEING")
	else:
		serverQueue.append([parent.get_child(slotID), button_index, true])
		print("ERROR OCCURED FROM SERVER CLICK; SLOT NOT READY: QUEUEING")
		
var hoveringOn = null

var hoveringWindowSlot = null
var hoveringWindow = null
		
func onSlotEnter(slot : CardSlot):
	if hoveringOn != null:
		onSlotExit(hoveringOn)
		
	hoveringOn = slot
	
	if Settings.gameMode == GAME_MODE.PLAYING and slot.currentZone == CardSlot.ZONES.HAND and slot.playerID == players[0].UUID and activePlayer == 0:
		if hoveringOn.cardNode != null and not cardsHolding.has(slot) and cardsHolding.size() < 2:
			if cardsPlayed < cardsPerTurn:
				hoveringOn.cardNode.position.y -= 5
		
func onSlotExit(slot : CardSlot):
	if slot == hoveringOn:
		if Settings.gameMode == GAME_MODE.PLAYING and slot.currentZone == CardSlot.ZONES.HAND and slot.playerID == players[0].UUID and activePlayer == 0:
			if hoveringOn.cardNode != null and not cardsHolding.has(slot) and cardsHolding.size() < 2:
				if cardsPlayed < cardsPerTurn:
					hoveringOn.cardNode.position.y += 5
		hoveringOn = null
		
func onSlotBeingClicked(slot : CardSlot, button_index : int):
	actionQueue.append([slot, button_index])
		
func slotClicked(slot : CardSlot, button_index : int, fromServer = false) -> bool:
	
	if not Server.online and Settings.gameMode != GAME_MODE.REPLAY:
		return false
	
	if not is_instance_valid(slot):
		return false
		
	if gameOver:
		return false
		
	if activePlayer == -1:
		return false
		
	if Settings.gameMode == GAME_MODE.SPECTATE and not fromServer:
		return false
		
	if button_index == 1:
		if slot.currentZone == CardSlot.ZONES.HAND:
			if slot.playerID == players[activePlayer].UUID:
				#ADDING CARDS TO THE FUSION LIST
				if slot.playerID != players[0].UUID and not fromServer:
					return false
				
				if is_instance_valid(selectedCard):
					selectedCard.cardNode.rotation = 0
					selectRotTimer = 0
					selectedCard = null
				
				if is_instance_valid(slot.cardNode) and cardsPerTurn - cardsPlayed > 0:
					if cardsHolding.has(slot):
						cardsHolding.erase(slot)
						slot.position.y += cardDists
						if hoveringOn != null:
							onSlotExit(slot)
						slot.cardNode.position.y = slot.position.y
					else:
						if cardsPerTurn - cardsPlayed - cardsHolding.size() > 0:
							cardsHolding.append(slot)
							slot.position.y -= cardDists
							slot.cardNode.position.y = slot.position.y
						else:
							if cardsShaking.has(slot):
								MessageManager.notify("You may only play " + str(cardsPerTurn) + " per turn")
							cardsShaking[slot] = shakeMaxTime
							return false
					if activePlayer == 0:
						$CardsLeftIndicator_A.setCardData(cardsPerTurn - cardsPlayed - cardsHolding.size(), cardsHolding.size(), cardsPlayed)
					else:
						$CardsLeftIndicator_B.setCardData(cardsPerTurn - cardsPlayed - cardsHolding.size(), cardsHolding.size(), cardsPlayed)
				else:
					if cardsShaking.has(slot):
						MessageManager.notify("You may only play " + str(cardsPerTurn) + " per turn")
					cardsShaking[slot] = shakeMaxTime
					return false
		elif slot.currentZone == CardSlot.ZONES.CREATURE:
			if cardsHolding.size() > 0 and fuseQueue.size() == 0:
				#PUTTING A CREATURE ONTO THE FIELD
				
				if is_instance_valid(slot.cardNode) and not slot.cardNode.card.canFuseThisTurn:
					if cardsShaking.has(slot):
						MessageManager.notify("This creature cannot be fused this turn")
					cardsShaking[slot] = shakeMaxTime
					return false
				##
				if is_instance_valid(slot.cardNode):
					var cardA = slot.cardNode.card
					for c in cardsHolding:
						var cardB = ListOfCards.fusePair(cardA, c.cardNode.card)
						if Card.areIdentical(cardA.serialize(), cardB.serialize()):
							if cardsShaking.has(slot):
								MessageManager.notify("A creature can only fuse to have two types")
							cardsShaking[slot] = shakeMaxTime
							return false
						else:
							cardA = cardB
				##
				
				
				
				var cardList = []
					
				for c in cardsHolding:
					cardList.append(c.cardNode.card)
					
				cardsPlayed += cardsHolding.size()
					
				if Settings.playAnimations:
					isEntering = not is_instance_valid(slot.cardNode)
					
					if is_instance_valid(slot.cardNode):
						if slot == selectedCard:
							selectedCard.cardNode.rotation = 0
							selectRotTimer = 0
							selectedCard = null
						cardsHolding.insert(0, slot)
						
					while cardsHolding.size() > 0:
						var c = cardsHolding[0]
						var cardNode = c.cardNode
						cardNode.setCardVisible(true)
						cardsHolding.erase(c)
						fuseQueue.append(cardNode)
						cardNode.get_parent().remove_child(cardNode)
						$Fusion_Holder.add_child(cardNode)
						cardNode.position = Vector2()
						c.cardNode = null
						card_A_Holder.cardNodes.erase(cardNode)
						card_B_Holder.cardNodes.erase(cardNode)
						if c.currentZone == CardSlot.ZONES.HAND:
							card_A_Holder.cardSlotNodes.erase(c)
							card_B_Holder.cardSlotNodes.erase(c)
							c.queue_free()
					
					fuseStartPos = fuseQueue[0].global_position
					fuseEndSlot = slot
					fuseTimer = 0
					fuseReturnTimer = 0
					
					
					card_A_Holder.centerCards(cardWidth, cardDists)
					card_B_Holder.centerCards(cardWidth, cardDists)
					centerNodes($Fusion_Holder.get_children(), Vector2(), cardWidth, cardDists)
					
					fuseWaiting = true
					fuseWaitTimer = 0
				else:
					isEntering = not is_instance_valid(slot.cardNode)
	
					if is_instance_valid(slot.cardNode):
						if not slot.cardNode.card.canFuseThisTurn:
							return false
						cardsHolding.insert(0, slot)
						cardList.insert(0, slot.cardNode.card)
						
					while cardsHolding.size() > 0:
						var c = cardsHolding[0]
						cardsHolding.remove(0)
						var cardNode = c.cardNode
						cardNode.get_parent().remove_child(cardNode)
						card_A_Holder.cardNodes.erase(cardNode)
						card_B_Holder.cardNodes.erase(cardNode)
						if c.currentZone == CardSlot.ZONES.HAND:
							card_A_Holder.cardSlotNodes.erase(c)
							card_B_Holder.cardSlotNodes.erase(c)
							c.queue_free()
					
					var newCard = ListOfCards.fuseCards(cardList)
					var cardPlacing = cardNode.instance()
					newCard.playerID = slot.playerID
					cardPlacing.card = newCard
					newCard.cardNode = cardPlacing
					creatures_A_Holder.add_child(cardPlacing)
					cardPlacing.global_position = slot.global_position
					cardPlacing.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
					if is_instance_valid(slot.cardNode):
						slot.cardNode.queue_free()
					slot.cardNode = cardPlacing
					cardPlacing.slot = slot
					
					if isEntering:
						newCard.onEnter(self, slot)
						for s in creatures[slot.playerID]:
							if is_instance_valid(s.cardNode) and s != slot:
								s.cardNode.card.onOtherEnter(self, slot)
					else:
						newCard.onEnterFromFusion(self, slot)
						for s in creatures[slot.playerID]:
							if is_instance_valid(s.cardNode) and s != slot:
								s.cardNode.card.onOtherEnterFromFusion(self, slot)
					
					checkState()
					
					card_A_Holder.centerCards(cardWidth, cardDists)
					card_B_Holder.centerCards(cardWidth, cardDists)
						

				if activePlayer == 0:
					$CardsLeftIndicator_A.setCardData(cardsPerTurn - cardsPlayed, 0, cardsPlayed)
				else:
					$CardsLeftIndicator_B.setCardData(cardsPerTurn - cardsPlayed, 0, cardsPlayed)
					
			else:
				if activePlayer != 0 and not fromServer:
					return false
				if slot.playerID == players[activePlayer].UUID:
					#ATTACKING
					if is_instance_valid(slot) and selectedCard == slot:
						selectedCard.cardNode.rotation = 0
						selectRotTimer = 0
						selectedCard = null
					else:
						if is_instance_valid(slot.cardNode) and (not slot.cardNode.card.hasAttacked and slot.cardNode.card.canAttackThisTurn):
							if is_instance_valid(selectedCard):
								selectedCard.cardNode.rotation = 0
							selectRotTimer = 0
							selectedCard = slot
						else:
							if cardsShaking.has(slot):
								MessageManager.notify("This creature cannot attack")
							cardsShaking[slot] = shakeMaxTime
							return false
				else:
					if is_instance_valid(selectedCard):
						var slots = []
						if ListOfCards.hasAbility(selectedCard.cardNode.card, AbilityPronged):
							slots = slot.getNeighbors()
						else:
							slots = [slot]
							
						selectedCard.cardNode.attack(self, slots)
						if is_instance_valid(selectedCard.cardNode):
							selectedCard.cardNode.rotation = 0
							selectRotTimer = 0
						selectedCard = null
							
	#CODE IS ONLY REACHABLE IF NOT RETURNED
	if Settings.gameMode == GAME_MODE.PLAYING:
		dataLog.append(("OWN_" if not fromServer else "OPPONENT_") + "SLOT " + str(slot.isOpponent) + " " + str(slot.currentZone) + " " + str(slot.get_index()))
	if not fromServer:
		Server.slotClicked(slot.isOpponent, slot.currentZone, slot.get_index(), button_index)
		
	return true

func isMyTurn() -> bool:
	return 0 == activePlayer

func _input(event):
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.scancode == KEY_Q:
			if isMyTurn():
				var waiting = true
				while waiting:
					var attacking = false
					for slot in creatures[players[activePlayer].UUID]:
						if is_instance_valid(slot.cardNode) and slot.cardNode.attacking:
							attacking = true
					if not attacking:
						waiting = false
							
					for p in players:
						if p.hand.drawQueue.size() > 0:
							waiting = true
							
					if fuseQueue.size() > 0:
						waiting = true
							
					if millQueue.size() > 0:
						waiting = true
							
					if actionQueue.size() > 0:
						waiting = true
							
					yield(get_tree().create_timer(0.1), "timeout")
				nextTurn()
				Server.onNextTurn()

	if event is InputEventMouseButton and event.pressed and event.button_index == 2:
		if is_instance_valid(hoveringWindow):
			hoveringWindow.close()
			hoveringWindowSlot = null
		else:
			if is_instance_valid(hoveringOn):
				if hoveringOn.currentZone == CardSlot.ZONES.DECK:
					var numCards = players[1 if hoveringOn.isOpponent else 0].deck.cards.size()
					var pos = hoveringOn.global_position + Vector2(cardWidth * 3.0/5, 0)
					createHoverNode(pos, str(numCards))
					hoveringWindowSlot = hoveringOn
					
				elif is_instance_valid(hoveringOn.cardNode) and hoveringOn.cardNode.cardVisible and hoveringOn.cardNode.card != null:
					var pos = hoveringOn.global_position + Vector2(cardWidth * 3.0/5 * Settings.cardSlotScale, 0)
					createHoverNode(pos, hoveringOn.cardNode.card.getHoverData())
					hoveringWindowSlot = hoveringOn
			
func nextTurn():
	if gameOver:
		return
	#Engine.time_scale = 0.1
	if Settings.gameMode == GAME_MODE.PLAYING:
		dataLog.append("NEXT_TURN")
	
	while cardsHolding.size() > 0:
		cardsHolding[0].position.y += cardDists
		cardsHolding[0].cardNode.position.y = cardsHolding[0].position.y
		cardsHolding.remove(0)
	if is_instance_valid(selectedCard):
		selectedCard.cardNode.rotation = 0
		selectedCard = null
		
	checkState()
		
	######################	ON END OF TURN EFFECTS
	for slot in boardSlots:
		if is_instance_valid(slot.cardNode):
			slot.cardNode.card.onEndOfTurn(self)
	######################
		
	cardsPlayed = 0
	activePlayer = (activePlayer + 1) % players.size()
	if activePlayer == 0:
		$TurnIndicator.startTurn()
	players[activePlayer].hand.drawCard()
		
	if activePlayer == 0:
		$CardsLeftIndicator_A.setCardData(cardsPerTurn - cardsPlayed - cardsHolding.size(), cardsHolding.size(), cardsPlayed)
	else:
		$CardsLeftIndicator_B.setCardData(cardsPerTurn - cardsPlayed - cardsHolding.size(), cardsHolding.size(), cardsPlayed)
		
	######################	ON START OF TURN EFFECTS
	var slotsToCheck = []
	for slot in boardSlots:
		if is_instance_valid(slot.cardNode):
			slotsToCheck.append(slot)
	for slot in slotsToCheck:
			slot.cardNode.card.onStartOfTurn(self)
	######################

func checkState():
	var boardState = []
	var slots = []
	for p in players:
		for s in creatures[p.UUID]:
			if is_instance_valid(s.cardNode):
				boardState.append(s.cardNode.card.serialize())
			else:
				boardState.append({})
	
	var creaturesDying = []
	for p in players:
		for s in creatures[p.UUID]:
			if is_instance_valid(s.cardNode):
				if s.cardNode.card.toughness <= 0:
					creaturesDying.append(s.cardNode)
				
	for cardNode in creaturesDying:
		if hoveringWindowSlot == cardNode.slot:
			hoveringWindow.close()
			hoveringWindowSlot = null
					
		cardNode.card.onLeave(self)
		cardNode.slot.cardNode = null
		cardNode.card.onDeath(self)
		cardNode.queue_free()
		for s in creatures[cardNode.slot.playerID]:
			if is_instance_valid(s.cardNode) and s != cardNode.slot:
				s.cardNode.card.onOtherLeave(self, cardNode.slot)
				s.cardNode.card.onOtherDeath(self, cardNode.slot)

	var boardStateNew = []
	for p in players:
		for s in creatures[p.UUID]:
			if is_instance_valid(s.cardNode):
				boardStateNew.append(s.cardNode.card.serialize())
			else:
				boardStateNew.append({})
				
	for i in range(boardState.size()):
		if not Card.areIdentical(boardState[i], boardStateNew[i]):
			#yield(get_tree().create_timer(0.1), "timeout")
			checkState()

func onLoss(player : Player):
	gameOver = true
	get_node("/root/main/WinLose").showWinLose(player != players[0])

var dataLog := []

var replayIndex = 0
var replayTimer = 0
var replayWaiting = false

func saveReplay():
	print("NOTICE: DUMPING GAME LOG")
	FileIO.dumpDataLog(dataLog)

func setSpectatorData(data):
	visible = false
	settingSpectateData = true
	var anims = Settings.playAnimations
	Settings.playAnimations = false
	for i in range(data.size()):
		processReplayCommand(data[i])
		yield(get_tree().create_timer(0.02), "timeout")
		
	Settings.playAnimations = anims
	settingSpectateData = false
	visible = true

func serialize() -> Array:
	var rtn = []
	
	#Version ID, current player, health
	#Cards selected, cards held, millQueue size, creatures attacking
	#Decks, 
	#Hands, 
	#Creatures
	return rtn
	
func deserialize(data : Array):
	pass
