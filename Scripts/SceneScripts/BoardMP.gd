
extends Node2D

class_name BoardMP

var cardSlot = preload("res://Scenes/CardSlot.tscn")
var cardNode = preload("res://Scenes/CardNode.tscn")
onready var cardWidth = ListOfCards.cardBackground.get_width()
onready var cardHeight = ListOfCards.cardBackground.get_height()
var hoverScene = preload("res://Scenes/UI/Hover.tscn")

var cardDists = 16

var creatures : Dictionary
var graves : Dictionary
var decks : Dictionary
var fusionHolders : Dictionary

var boardSlots : Array

var players : Array
var activePlayer := -1
var playedThisTurn = false

onready var creatures_A_Holder = $Creatures_A
onready var creatures_B_Holder = $Creatures_B
onready var graveHolder = $GraveHolder
onready var deckHolder = $DeckHolder
onready var card_A_Holder = $Card_A_Holder
onready var card_B_Holder = $Card_B_Holder
onready var fusion_A_Holder = $Fusion_A_Holder
onready var fusion_B_Holder = $Fusion_B_Holder

var cardsHolding : Array
var selectedCard : CardSlot
var selectRotTimer = 0

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
var fuseWaitMaxTime = 0.2

var gameStarted = false
var gameOver = false

enum GAME_MODE {PLAYING, SPECTATE, REPLAY}

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
	var player_A = Player.new(cardList, self)
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
				
	var player_B = Player.new(cards, self)
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

func _physics_process(delta):
	
	if Settings.gameMode == GAME_MODE.REPLAY and not replayWaiting and not gameOver:
		replayTimer += delta
		if replayTimer >= 0.3:
			nextReplayAction()
	
	if readyToStart and deckDataSet and hasStartingPlayer and versionConfirmed:
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
		
	if playerRestart and opponentRestart:
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
					cardNode.card.onEnter(self)
					hoverTimer = 0
					shownHover = false
	
	if hoveringOn != null:
		if not shownHover:
			hoverTimer += delta
			if hoverTimer > hoverMaxTime * (0.2 if hoveringOn.currentZone == CardSlot.ZONES.DECK else 1):
				shownHover = true
				if hoveringOn.currentZone == CardSlot.ZONES.DECK:
					var numCards = players[1 if hoveringOn.isOpponent else 0].deck.cards.size()
					var pos = hoveringOn.global_position + Vector2(cardWidth * 3.0/5, 0)
					createHoverNode(pos, str(numCards))
					
				elif is_instance_valid(hoveringOn.cardNode) and hoveringOn.cardNode.cardVisible and hoveringOn.cardNode.card != null:
					var pos = hoveringOn.global_position + Vector2(cardWidth * 3.0/5, 0)
					createHoverNode(pos, hoveringOn.cardNode.card.getHoverData())

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
		creatures[p.UUID].append(cardInst)
		boardSlots.append(cardInst)
	centerNodes(creatures[p.UUID], Vector2(), cardWidth, cardDists)
	
	cardInst = cardSlot.instance()
	cardInst.currentZone = CardSlot.ZONES.GRAVE
	cardInst.board = self
	cardInst.playerID = p.UUID
	graveHolder.add_child(cardInst)
	cardInst.position = Vector2(0, cardHeight + cardDists)
	
	cardInst = cardSlot.instance()
	cardInst.currentZone = CardSlot.ZONES.DECK
	cardInst.board = self
	cardInst.playerID = p.UUID
	deckHolder.add_child(cardInst)
	cardInst.position = Vector2(0, cardHeight + cardDists)
	var cardNodeInst = cardNode.instance()
	cardNodeInst.card = ListOfCards.getCard(0)
	cardNodeInst.cardVisible = false
	cardNodeInst.playerID = p.UUID
	cardInst.add_child(cardNodeInst)
	cardInst.cardNode = cardNodeInst
	cardNodeInst.position = Vector2()
	decks[p.UUID] = cardInst
	
	fusionHolders[p.UUID] = fusion_A_Holder
	
	
	#	PLAYER 2 SLOTS  	#
	p = players[1]
	
	for i in range(p.creatureNum):
		cardInst = cardSlot.instance()
		cardInst.isOpponent = true
		cardInst.currentZone = CardSlot.ZONES.CREATURE
		cardInst.board = self
		cardInst.playerID = p.UUID
		creatures_B_Holder.add_child(cardInst)
		creatures[p.UUID].append(cardInst)
		boardSlots.append(cardInst)
	centerNodes(creatures[p.UUID], Vector2(), cardWidth, cardDists)
	
	cardInst = cardSlot.instance()
	cardInst.currentZone = CardSlot.ZONES.GRAVE
	cardInst.isOpponent = true
	cardInst.board = self
	cardInst.playerID = p.UUID
	graveHolder.add_child(cardInst)
	cardInst.position = Vector2(0, -cardHeight - cardDists)
	
	cardInst = cardSlot.instance()
	cardInst.currentZone = CardSlot.ZONES.DECK
	cardInst.isOpponent = true
	cardInst.board = self
	cardInst.playerID = p.UUID
	deckHolder.add_child(cardInst)
	cardInst.position = Vector2(0, -cardHeight - cardDists)
	cardNodeInst = cardNode.instance()
	cardNodeInst.card = ListOfCards.getCard(0)
	cardNodeInst.cardVisible = false
	cardNodeInst.playerID = p.UUID
	cardInst.add_child(cardNodeInst)
	cardInst.cardNode = cardNodeInst
	cardNodeInst.position = Vector2()
	decks[p.UUID] = cardInst
		
	fusionHolders[p.UUID] = fusion_B_Holder
	
		
func initHands():
	$HealthNode.player = players[0]
	$HealthNode2.player = players[1]
	players[0].hand = card_A_Holder
	#players[0].initHand(self)
	players[1].hand = card_B_Holder
	#players[1].initHand(self)
	players[0].hand.deck = decks[players[0].UUID]
	players[1].hand.deck = decks[players[1].UUID]
				
static func centerNodes(nodes : Array, position : Vector2, cardWidth : int, cardDists : int):
	for i in range(nodes.size()):
		nodes[i].position = position + Vector2(-(nodes.size() - 1) / 2.0 * (cardWidth + cardDists) + (cardWidth + cardDists) * i, 0)
		
		
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
		CardSlot.ZONES.GRAVE:
			parent = graveHolder
		CardSlot.ZONES.DECK:
			parent = deckHolder
	
	slotClicked(parent.get_child(slotID), button_index, true)
		
var hoverTimer = 0
var hoverMaxTime = 1
var hoveringOn = null
var shownHover = false
var hoveringWindow = null
		
func onSlotEnter(slot : CardSlot):
	if hoveringOn != null:
		onSlotExit(hoveringOn)
		
	hoveringOn = slot
	hoverTimer = 0
	shownHover = false
	
	if Settings.gameMode == GAME_MODE.PLAYING and slot.currentZone == CardSlot.ZONES.HAND and slot.playerID == players[0].UUID and activePlayer == 0:
		if hoveringOn.cardNode != null and not cardsHolding.has(slot) and cardsHolding.size() < 2:
			hoveringOn.cardNode.position.y -= 5
		
func onSlotExit(slot : CardSlot):
	if slot == hoveringOn:
		if Settings.gameMode == GAME_MODE.PLAYING and slot.currentZone == CardSlot.ZONES.HAND and slot.playerID == players[0].UUID and activePlayer == 0:
			if hoveringOn.cardNode != null and not cardsHolding.has(slot) and cardsHolding.size() < 2:
				hoveringOn.cardNode.position.y += 5
		hoveringOn = null
		shownHover = false
		if is_instance_valid(hoveringWindow):
			hoveringWindow.fadeOut()
			hoveringWindow = null
		
func slotClicked(slot : CardSlot, button_index : int, fromServer = false):
	if gameOver:
		return
		
	if activePlayer == -1:
		return
		
	if Settings.gameMode == GAME_MODE.REPLAY and not fromServer:
		return
		
	if button_index == 1:
		if slot.playerID == players[activePlayer].UUID or slot.playerID == -1:
			if slot.currentZone == CardSlot.ZONES.HAND:
				#ADDING CARDS TO THE FUSION LIST
				if slot.playerID != players[0].UUID and not fromServer:
					return
				
				if is_instance_valid(slot.cardNode) and not playedThisTurn:
					if cardsHolding.has(slot):
						cardsHolding.erase(slot)
						slot.position.y += cardDists
						if hoveringOn != null:
							onSlotExit(slot)
						slot.cardNode.position.y = slot.position.y
					else:
						if cardsHolding.size() < 2:
							cardsHolding.append(slot)
							slot.position.y -= cardDists
							slot.cardNode.position.y = slot.position.y
			elif slot.currentZone == CardSlot.ZONES.CREATURE:
				if slot.playerID != players[0].UUID and not fromServer:
					return
				if cardsHolding.size() > 0:
					#PUTTING A CREATURE ONTO THE FIELD
					var endsCreature = false
					
					var cardList = []
					if is_instance_valid(slot.cardNode):
						cardList.append(slot.cardNode.card)
					for c in cardsHolding:
						cardList.append(c.cardNode.card)
					var newCard = ListOfCards.fuseCards(cardList)
					endsCreature = (newCard != null and newCard.cardType == Card.CARD_TYPE.Creature)
					
					if endsCreature:
						
						if Settings.playAnimations:
						
							if is_instance_valid(slot.cardNode):
								cardsHolding.insert(0, slot)
								
							while cardsHolding.size() > 0:
								var c = cardsHolding[0]
								var cardNode = c.cardNode
								cardNode.setCardVisible(true)
								cardsHolding.erase(c)
								fuseQueue.append(cardNode)
								cardNode.get_parent().remove_child(cardNode)
								fusionHolders[slot.playerID].add_child(cardNode)
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
							centerNodes(fusion_A_Holder.get_children(), Vector2(), cardWidth, cardDists)
							centerNodes(fusion_B_Holder.get_children(), Vector2(), cardWidth, cardDists)
							
							fuseWaiting = true
							fuseWaitTimer = 0
							playedThisTurn = true
						else:

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
									
							var cardPlacing = cardNode.instance()
							newCard.playerID = slot.playerID
							cardPlacing.card = newCard
							creatures_A_Holder.add_child(cardPlacing)
							cardPlacing.global_position = slot.global_position
							if is_instance_valid(slot.cardNode):
								slot.cardNode.queue_free()
							slot.cardNode = cardPlacing
							cardPlacing.slot = slot
							
							newCard.onEnter(self)
							playedThisTurn = true
							
							card_A_Holder.centerCards(cardWidth, cardDists)
							card_B_Holder.centerCards(cardWidth, cardDists)
							
				else:
					#ATTACKING
					if is_instance_valid(slot) and selectedCard == slot:
						selectedCard.cardNode.rotation = 0
						selectRotTimer = 0
						selectedCard = null
					else:
						if is_instance_valid(slot.cardNode) and not slot.cardNode.card.hasAttacked:
							if is_instance_valid(selectedCard):
								selectedCard.cardNode.rotation = 0
							selectRotTimer = 0
							selectedCard = slot
						
			elif slot.currentZone == CardSlot.ZONES.GRAVE:
				pass
			else:
				pass
		else:
			if slot.currentZone == CardSlot.ZONES.CREATURE:
				if slot.playerID != players[1].UUID and not fromServer:
					return
				if is_instance_valid(slot.cardNode) and is_instance_valid(selectedCard):
					selectedCard.cardNode.card.onAttack(slot, self)
					slot.cardNode.card.onBeingAttacked(selectedCard, self)
					selectedCard.cardNode.attack(slot.global_position + (selectedCard.cardNode.global_position - slot.global_position).normalized() * cardHeight, slot)
					
					
					if is_instance_valid(selectedCard.cardNode):
						selectedCard.cardNode.rotation = 0
						selectRotTimer = 0
						
					selectedCard = null
				elif is_instance_valid(selectedCard):
#					var foundCreature = false
#					for s in creatures[slot.playerID]:
#						if is_instance_valid(s.cardNode):
#							foundCreature = true
#					if not foundCreature:
					for p in players:
						if p.UUID == slot.playerID:
							selectedCard.cardNode.card.onAttack(null, self)
							selectedCard.cardNode.attack(slot.global_position + (selectedCard.cardNode.global_position - slot.global_position).normalized() * cardHeight, slot)
							selectedCard.cardNode.rotation = 0
							selectRotTimer = 0
							selectedCard = null
							
	#CODE IS ONLY REACHABLE IF NOT RETURNED
	if Settings.gameMode == GAME_MODE.PLAYING:
		dataLog.append(("OWN_" if not fromServer else "OPPONENT_") + "SLOT " + str(slot.isOpponent) + " " + str(slot.currentZone) + " " + str(slot.get_index()))
	if not fromServer:
		Server.slotClicked(slot.isOpponent, slot.currentZone, slot.get_index(), button_index)

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
							
					yield(get_tree().create_timer(0.1), "timeout")
				nextTurn()
				Server.onNextTurn()
			
			
func nextTurn():
	if gameOver:
		return
	#Engine.time_scale = 0.1
	print("NEXT TURN")
	if Settings.gameMode == GAME_MODE.PLAYING:
		dataLog.append("NEXT_TURN")
	
	while cardsHolding.size() > 0:
		cardsHolding[0].position.y += cardDists
		cardsHolding[0].cardNode.position.y = cardsHolding[0].position.y
		cardsHolding.remove(0)
	if is_instance_valid(selectedCard):
		selectedCard.cardNode.rotation = 0
		selectedCard = null
		
	######################	ON END OF TURN EFFECTS
	for slot in boardSlots:
		if is_instance_valid(slot.cardNode):
			slot.cardNode.card.onEndOfTurn(self)
	######################
		
	playedThisTurn = false
	activePlayer = (activePlayer + 1) % players.size()
	players[activePlayer].hand.drawCard()
		
	######################	ON START OF TURN EFFECTS
	var slotsToCheck = []
	for slot in boardSlots:
		if is_instance_valid(slot.cardNode):
			slotsToCheck.append(slot)
	for slot in slotsToCheck:
			slot.cardNode.card.onStartOfTurn(self)
	######################

func onLoss(player : Player):
	gameOver = true
	get_node("/root/main/WinLose").showWinLose(player != players[0])

var dataLog := []

var replayIndex = 0
var replayTimer = 0
var replayWaiting = false

func _exit_tree():
	if Settings.gameMode == GAME_MODE.PLAYING:
		print("NOTICE: DUMPING GAME LOG")
		FileIO.dumpDataLog(dataLog)
