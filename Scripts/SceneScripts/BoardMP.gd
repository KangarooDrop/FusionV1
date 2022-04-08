
extends Node2D

class_name BoardMP

var deadPlayers = []

var cardSlot = preload("res://Scenes/CardSlot.tscn")
var cardNode = preload("res://Scenes/CardNode.tscn")
onready var cardWidth = ListOfCards.cardBackground.get_width()
onready var cardHeight = ListOfCards.cardBackground.get_height()
var hoverScene = preload("res://Scenes/UI/Hover.tscn")
var fadingScene = preload("res://Scenes/UI/FadingNode.tscn")

var cardDists = 16

var creatures : Dictionary
var decks : Dictionary
var graves : Dictionary
var graveCards : Dictionary

var boardSlots : Array

var players : Array
var activePlayer := -1
var cardsPerTurnMax = 2
var cardsPerTurn = cardsPerTurnMax
var cardsPlayed = 0

var shakeMaxTime = 0.5
var shakeAmount = 0.8
var shakeFrequency = 6
var cardsShaking := {}

onready var creatures_A_Holder = $Creatures_A
onready var creatures_B_Holder = $Creatures_B
onready var deckHolder = $DeckHolder
onready var card_A_Holder = $Hand_A
onready var card_B_Holder = $Hand_B

var cardsHolding : Array
var selectedCard : CardSlot
var highlightedSlots := []
var selectRotTimer = 0

var actionQueue : Array

var millQueue : Array
var millNode
var millWaitTimer = 0
var millWaitMaxTime = 0.5

var isEntering = false
var cardNodesFusing : Array
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

var abilityStack : AbilityStack = AbilityStack.new()
var currentAbility = null
var waitingAbilities := []

var opponentID = -1
var gameSeed = -1

var deckDataSet = false
var readyToStart = false
var hasStartingPlayer = false
var versionConfirmed = false

var mulliganDone = false
var mulliganDoneOpponent = false
var oldHandPos = 0
var handMoveTimer = 0
var handMoveMaxTime = 0.5
var handMoving = false

var rightClickQueue := []

var boardReady = false

var selectingSlot = false
var selectingSource = null
var selectingUUID = -1
var stackMaxTime = 1
var stackTimer = 0

func _ready():
	print("-".repeat(30))
	
	if not Server.online:
		mulliganDoneOpponent = true
		versionConfirmed = true
		readyToStart = true
		opponentRestart = true
		
		#print(readyToStart, " and ", deckDataSet, " and ", hasStartingPlayer, " and ", versionConfirmed, " and ", (gameSeed != -1), " and ", mulliganDone, " and ", mulliganDoneOpponent)
	
	players.append(Player.new($HealthNode, $ArmourNode))
	creatures[players[0].UUID] = []
	players.append(Player.new($HealthNode2, $ArmourNode2))
	players[1].isOpponent = true
	players[1].isPractice = Settings.gameMode == Settings.GAME_MODE.PRACTICE
	creatures[players[1].UUID] = []
	
	initZones()
	initHands()
	
	if opponentID == -1:
		if Server.playerIDs.size() > 0:
			opponentID = Server.playerIDs[0]
	
	if not Server.online or Server.host:
		setGameSeed(OS.get_system_time_msecs())
		Server.setGameSeed(opponentID, gameSeed + 1)
	
	if not Server.online or Server.host:
		var startingPlayerIndex = randi() % 2
		setStartingPlayer((startingPlayerIndex + 1) % 2)
		print("Send: Starting player")
		dataLog.append("SET_PLAYER " + str((startingPlayerIndex + 1) % 2))
		Server.setActivePlayer(opponentID, startingPlayerIndex)
		hasStartingPlayer = true

	Server.fetchVersion(opponentID)
	
	setOwnUsername()
	
	initCardsLeftIndicator()

func initCardsLeftIndicator():
	if activePlayer == 0:
		$CardsLeftIndicator_A.setCardData(cardsPerTurn, 0, 0)
		$CardsLeftIndicator_B.setCardData(0, 0, cardsPerTurn)
	else:
		$CardsLeftIndicator_A.setCardData(0, 0, cardsPerTurn)
		$CardsLeftIndicator_B.setCardData(cardsPerTurn, 0, 0)
	

func setGameSeed(gameSeed : int):
	self.gameSeed = gameSeed
	print("current game seed is ", gameSeed)
	seed(gameSeed)
	dataLog.append("SET_SEED " + str(gameSeed))
	
	var cardData = getDeckFromFile()
	var cardList = cardData[0]
	var van
	if cardData[1].size() > 0:
		van = cardData[1][0]
	cardList.shuffle()
	setOwnCardList(cardList, van)
		
	print("Fetch: Opponent's deck list")
	Server.sendDeck(opponentID)

func startMulligan():
	if not Server.host:
		while gameSeed == -1:
			yield(get_tree().create_timer(0.1), "timeout")
			print("waiting for seed")
	print("Starting mulligan")
	oldHandPos = card_A_Holder.rect_position.y
	card_A_Holder.rect_position.y = 0
	players[0].hand.drawHand()

func onMulliganButtonPressed():
	if players[0].hand.drawQueue.size() == 0:
		var handCards = []
		if not Server.online or Server.host:
			for i in range(players[0].hand.nodes.size()):
				handCards.append(players[0].hand.nodes[i].card)
			while players[0].hand.nodes.size() > 0:
				players[0].hand.nodes[0].queue_free()
				players[0].hand.nodes.remove(0)
				players[0].hand.slots[0].queue_free()
				players[0].hand.slots.remove(0)
			
			for i in range(players[0].deck.cards.size()):
				handCards.append(players[0].deck.cards[i])
			
			handCards.shuffle()
			players[0].deck.setCards(handCards, players[0].UUID, true)
			
			Server.sendDeck(opponentID)
			
			players[0].hand.drawHand()
			mulliganDone = true
			handMoving = true
			
		else:
			while players[0].hand.nodes.size() > 0:
				players[0].hand.nodes[0].queue_free()
				players[0].hand.nodes.remove(0)
				players[0].hand.slots[0].queue_free()
				players[0].hand.slots.remove(0)
			Server.requestMulligan(opponentID)
		
		$KeepButton.visible = false
		$MulliganButton.visible = false
		Server.mulliganDone(opponentID)

func mulliganOpponent():
	players[1].deck.shuffle()
	Server.sendMulliganDeck(opponentID)

func mulliganOpponentDone():
	mulliganDoneOpponent = true

func onKeepButtonPressed():
	$KeepButton.visible = false
	$MulliganButton.visible = false
	Server.mulliganDone(opponentID)
	mulliganDone = true
	handMoving = true

func getDeckFromFile() -> Array:
	var fileName = Settings.selectedDeck
	var path = Settings.path
	
	var dataRead = FileIO.readJSON(path + fileName)
	var error = Deck.verifyDeck(dataRead)
	var cardList := [[], []]
	
	if error == Deck.DECK_VALIDITY_TYPE.VALID:
		for k in dataRead["cards"].keys():
			var id = int(k)
			for i in range(int(dataRead["cards"][k])):
				cardList[0].append(ListOfCards.getCard(id))
		for k in dataRead["vanguard"].keys():
			cardList[1].append(ListOfCards.getCard(int(k)))
	else:
		MessageManager.notify("Invalid Deck:\nverify deck file contents")
		Server.disconnectMessage(opponentID, "Error: Opponent's deck is invalid")
		print("INVALID DECK : ", error, " : ", Deck.DECK_VALIDITY_TYPE.keys()[error])
	
		var sceneError = get_tree().change_scene("res://Scenes/StartupScreen.tscn")
		if sceneError != 0:
			print("Error loading test1.tscn. Error Code = " + str(sceneError))
			
	return cardList

func setOwnCardList(cardList : Array, vanguard):
	players[0].deck.setCards(cardList, players[0].UUID, true)
	players[0].deck.setVanguard(vanguard)
	var logDeck = "OWN_DECK "
	for i in players[0].deck.serialize():
		logDeck += str(i) + " "
	
	if Settings.gameMode == Settings.GAME_MODE.PRACTICE:
		var data = players[0].deck.getJSONData()
		var order = players[0].deck.serialize()
		setDeckData(data, order)
	
	dataLog.append(logDeck)

func setOpponentCardList(cardList : Array, vanguard):
	var cards = []
	for c in cardList:
		cards.append(ListOfCards.getCard(c))
	players[1].deck.setCards(cards, players[1].UUID, true)
	players[1].deck.setVanguard(vanguard)
	
	var logDeck = "OPPONENT_DECK "
	for i in players[players.size()-1].deck.serialize():
		logDeck += str(i) + " "
	
	dataLog.append(logDeck)

func setDeckData(data, order):
	
	print("Receive: Opponent deck data")
	
	var good = verifyDeckData(data, order)
	if good:
		var van
		if data["vanguard"].keys().size() > 0:
			van = ListOfCards.getCard(data["vanguard"][data["vanguard"].keys()[0]])
		setOpponentCardList(order, van)
	else:
		MessageManager.notify("Opponent's deck is invalid")
		Server.disconnectMessage(opponentID, "Error: Your deck has been flagged by the opponent as invalid")
		print("INVALID DECK OPPONENT")
	
		var sceneError = get_tree().change_scene("res://Scenes/StartupScreen.tscn")
		if sceneError != 0:
			print("Error loading test1.tscn. Error Code = " + str(sceneError))
	
	print("Send: Game start signal")
	Server.onGameStart(opponentID)
	deckDataSet = true

func verifyDeckData(data, order) -> bool:
	var error = Deck.verifyDeck(data)
	if error == Deck.DECK_VALIDITY_TYPE.VALID:
		
		data = data["cards"]
		
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
	dataLog.append("VERSION " + version)
	var error = Settings.compareVersion(Settings.versionID, version)
	if error == 0:
		versionConfirmed = true
	else:
		MessageManager.notify("Error: Incompatable game versions")
		Server.disconnectMessage(opponentID, "Error: Incompatable game versions")
		print("INVALID VERSIONS")
	
		var sceneError = get_tree().change_scene("res://Scenes/StartupScreen.tscn")
		if sceneError != 0:
			print("Error loading test1.tscn. Error Code = " + str(sceneError))

func onGameStart():
	print("Receive: Ready to start")
	readyToStart = true

func setStartingPlayer(playerIndex : int):
	print("Receive: Starting player")
	dataLog.append("SET_PLAYER " + str(playerIndex))
	activePlayer = playerIndex
	hasStartingPlayer = true
	
	startMulligan()
	
	initCardsLeftIndicator()
	
	setTurnText()

var playerRestart = false
var opponentRestart = false
func onRestartPressed():
	if not playerRestart and not opponentRestart:
		MessageManager.notify("Opponent has requested to restart")
	opponentRestart = true

func startGame():
	players[1].hand.drawHand()
	
	readyToStart = false
	deckDataSet = false
	versionConfirmed = false
	hasStartingPlayer = false
	gameStarted = true
	print("Notice: Players ready, starting game")
	dataLog.append("GAME_START")
	
	setTurnText()

func setTurnText():
	if activePlayer == 0:
		$TI/Label.text = "Your\nTurn"
		if gameStarted:
			$EndTurnButton.visible = true
	else:
		$TI/Label.text = "Opponent\nTurn"
		$EndTurnButton.visible = false

func getCanFight() -> bool:
	return (abilityStack.size() == 0 or abilityStack.getFront()["canAttack"]) and cardNodesFusing.size() == 0 and millQueue.size() == 0 and not isDrawing()

var rotTimer = 0
var rotAngle = PI / 2
var rotFreq = 1

var practiceWaiting = false

func _physics_process(delta):
	
	if not gameOver and deadPlayers.size() > 0:
		gameOver = true
		var out
		if deadPlayers.size() == 1:
			if deadPlayers[0] == players[0]:
				out = 1
			elif deadPlayers[0] == players[1]:
				out = 0
		elif deadPlayers.size() == players.size():
			out = 2
		get_node("/root/main/CenterControl/WinLose").showWinLose(out)
		deadPlayers.clear()
	
	if Settings.gameMode == Settings.GAME_MODE.PRACTICE:
		if not practiceWaiting and activePlayer != 0 and gameStarted and not getWaiting():
			practiceWaiting = true
			yield(get_tree().create_timer(1), "timeout")
			if not getWaiting() and activePlayer != 0:
				nextTurn()
			practiceWaiting = false
	
	if readyToStart and deckDataSet and hasStartingPlayer and versionConfirmed and gameSeed != -1 and mulliganDone and mulliganDoneOpponent:
		startGame()
	
	if playerRestart and opponentRestart:
		print("REEEEEEEEEESPAWN!")
		var error = get_tree().change_scene("res://Scenes/main.tscn")
		if error != 0:
			print("Error loading test1.tscn. Error Code = " + str(error))
		
		
	
	if handMoving and players[0].hand.drawQueue.size() == 0:
		handMoveTimer += delta
		if handMoveTimer < handMoveMaxTime:
			card_A_Holder.rect_position.y = lerp(0, oldHandPos, handMoveTimer / handMoveMaxTime)
		else:
			handMoving = false
			card_A_Holder.rect_position.y = oldHandPos
	
	if gameStarted:
		rotAngle = PI / 32
		rotFreq = 0.2
		if isMyTurn():
			rotTimer += delta
		else:
			rotTimer = 0
		$TI.rotation = sin(2 * PI * rotTimer * rotFreq) * rotAngle
		
	if is_instance_valid(hoveringWindowSlot):
		if hoveringWindowSlot.currentZone == CardSlot.ZONES.DECK:
			var string = ""
			var p = players[1 if hoveringWindowSlot.isOpponent else 0]
			var numCards = p.deck.cards.size()
			if numCards == 0:
				string = "Take " + str(players[1 if hoveringWindowSlot.isOpponent else 0].drawDamage) + " damage on draw"
			else:
				string = str(numCards) + "/" + str(p.deck.deckSize)
			if hoveringWindow.text != string:
				hoveringWindow.visible = true
				hoveringWindow.setText(string)
		
	
	if is_instance_valid(selectedCard):
		selectRotTimer += delta
		selectedCard.cardNode.rotation = sin(selectRotTimer * 1.5) * PI / 32
	
	if cardNodesFusing.size() > 0:
		if fuseWaiting:
			fuseWaitTimer += delta
			if fuseWaitTimer >= fuseWaitMaxTime:
				fuseWaiting = false
		else:
			if cardNodesFusing.size() > 1:
				if not fusing:
					fusing = true
					fuseStartPos = cardNodesFusing[1].position
					fuseEndPos = cardNodesFusing[0].position
				if fusing:
					fuseTimer += delta
					if fuseTimer >= fuseMaxTime:
						fuseTimer = 0
						fusing = false
						cardNodesFusing[0].slot = fuseEndSlot
						cardNodesFusing[0].card = ListOfCards.fusePair(cardNodesFusing[0].card, cardNodesFusing[1].card, cardNodesFusing[0])
						cardNodesFusing[0].setCardVisible(true)
						cardNodesFusing[1].queue_free()
						cardNodesFusing.remove(1)
						fuseWaiting = true
						fuseWaitTimer = 0
						if cardNodesFusing.size() == 1:
							fuseStartPos = cardNodesFusing[0].global_position
							fuseReturnTimer = 0
					else:
						cardNodesFusing[1].position = lerp(fuseStartPos, fuseEndPos, fuseTimer / fuseMaxTime)
			elif cardNodesFusing.size() == 1:
				fuseReturnTimer += delta
				cardNodesFusing[0].global_position = lerp(fuseStartPos, fuseEndSlot.global_position, fuseReturnTimer / fuseReturnMaxTime)
				if fuseReturnTimer >= fuseReturnMaxTime:
					var cardNode = cardNodesFusing[0]
					fuseEndSlot.cardNode = cardNodesFusing[0]
					cardNode.get_parent().remove_child(cardNode)
					cardNode.slot = fuseEndSlot
					creatures_A_Holder.add_child(cardNode)
					cardNode.global_position = fuseEndSlot.global_position
					cardNodesFusing = []
					cardNode.card.playerID = fuseEndSlot.playerID
					cardNode.card.cardNode = cardNode
					
					var cs = getAllCards()
					if isEntering:
						for c in cs:
							if c != cardNode.card:
								c.onOtherEnter(fuseEndSlot)
						cardNode.card.onEnter(fuseEndSlot)
					else:
						for c in cs:
							if c != cardNode.card:
								c.onOtherEnterFromFusion(fuseEndSlot)
						cardNode.card.onEnterFromFusion(fuseEndSlot)
					
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
				
				if players[playerNum].deck.cards.size() <= 0 and is_instance_valid(decks[players[playerNum].UUID].cardNode):
					decks[players[playerNum].UUID].cardNode.queue_free()
					decks[players[playerNum].UUID].cardNode = null
					
			else:
				millQueue.remove(0)
				print("Player ID not found for mill")
				
			if card != null:
				var cn = cardNode.instance()
				cn.card = card
				add_child(cn)
				cn.z_index += 1
				cn.global_position = decks[players[playerNum].UUID].global_position
				cn.playerID = players[playerNum].UUID
				millNode = cn
			else:
				millQueue.remove(0)
		
		if is_instance_valid(millNode):
			if millWaitTimer < millWaitMaxTime:
				millWaitTimer += delta
				if millWaitTimer >= millWaitMaxTime:
					
					for c in getAllCards():
						c.onMill(millNode.card)
					
					addCardToGrave(millNode.playerID, ListOfCards.getCard(millNode.card.UUID))
					millNode.queue_free()
					millNode = null
					millQueue.remove(0)
					millWaitTimer = 0
				else:
					millNode.global_position = lerp(decks[millNode.playerID].global_position, graves[millNode.playerID].global_position, millWaitTimer / millWaitMaxTime)
					millNode.get_parent().remove_child(millNode)
					graves[millNode.playerID].add_child(millNode)
					
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
		if selectingSlot and selectingUUID == players[1].UUID and Settings.gameMode == Settings.GAME_MODE.PRACTICE:
			selectingSource.slotClicked(null)
		
		if not selectingSlot and cardNodesFusing.size() == 0 and players[0].hand.drawQueue.size() == 0 and players[0].hand.discardQueue.size() == 0 and players[1].hand.drawQueue.size() == 0 and players[1].hand.discardQueue.size() == 0 and millQueue.size() == 0:
			if abilityStack.size() > 0:
				currentAbility = abilityStack.getFront()
				
			if abilityStack.size() > 0 and not currentAbility["triggered"]:
				abilityStack.trigger(currentAbility)
				
			if abilityStack.size() > 0 and stackTimer <= 0:
				if not selectingSlot:
					if not waitingAbilities.has(currentAbility["source"]) or currentAbility["source"].checkWaiting():
						waitingAbilities.erase(currentAbility["source"])
						abilityStack.erase(currentAbility)
						currentAbility = null
				if abilityStack.size() > 0:
					stackTimer = stackMaxTime
					
			elif stackTimer > 0:
				stackTimer -= delta
				
			elif actionQueue.size() > 0:
				if is_instance_valid(actionQueue[0][0]):
					if (not is_instance_valid(actionQueue[0][0].cardNode) or not actionQueue[0][0].cardNode.attacking):
						slotClicked(actionQueue[0][0], actionQueue[0][1], false)
						actionQueue.remove(0)
				else:
					actionQueue.remove(0)
	
	if rightClickQueue.size() > 0:
		clickedOff = false
		var selectedSlot = rightClickQueue[0]
		
		for i in range(1, rightClickQueue.size()):
			if not is_instance_valid(selectedSlot.cardNode) or (is_instance_valid(rightClickQueue[i].cardNode) and rightClickQueue[i].cardNode.z_index > selectedSlot.cardNode.z_index):
				selectedSlot = rightClickQueue[i]
		rightClickQueue.clear()
		
		var isSame = hoveringWindowSlot == selectedSlot
		
		if is_instance_valid(selectedSlot) and not isSame:
			if is_instance_valid(hoveringWindow):
				if hoveringWindow.close(true):
					hoveringWindowSlot = null
			if is_instance_valid(selectedSlot) and not selectedSlot.currentZone == CardSlot.ZONES.GRAVE:
				var string = null
				var pos := Vector2()
				var flipped := false
				if selectedSlot.currentZone == CardSlot.ZONES.DECK:
					var numCards = players[1 if selectedSlot.isOpponent else 0].deck.cards.size()
					string = ""
					pos = selectedSlot.global_position - Vector2(cardWidth*selectedSlot.scale.x/2, 0)
					flipped = true
				elif is_instance_valid(selectedSlot.cardNode) and selectedSlot.cardNode.cardVisible and selectedSlot.cardNode.card != null:
					string = selectedSlot.cardNode.card.getHoverData()
					pos = selectedSlot.global_position + Vector2(cardWidth*selectedSlot.scale.x/2, 0)
				
				if string != null:
					createHoverNode(pos, self, string, flipped)
					hoveringWindowSlot = selectedSlot
					if string == "":
						hoveringWindow.visible = false
			elif selectedSlot.currentZone == CardSlot.ZONES.GRAVE:
				if graveCards[selectedSlot.playerID].size() > 0:
					if selectedSlot.playerID == graveViewing:
						clearGraveDisplay()
					else:
						clearGraveDisplay()
						graveViewing = selectedSlot.playerID
						var gr = graveCards[selectedSlot.playerID]
						for i in range(gr.size()):
							$GraveDisplay.addCard(gr[i])
				else:
					pass
			
		elif is_instance_valid(hoveringWindowSlot):
			if is_instance_valid(hoveringWindow):
				if hoveringWindow.close():
					hoveringWindowSlot = null
	elif clickedOff:
		clickedOff = false
		if is_instance_valid(hoveringWindow):
			if hoveringWindow.close():
				hoveringWindowSlot = null
		elif graveViewing != -1:
			clearGraveDisplay()

var graveViewing := -1

func addCardToGrave(playerID : int, card : Card):
	
	if card.tier != 1:
		return
	
	card.playerID = playerID
	
	graveCards[playerID].append(card)
	
	var cn = graves[playerID].cardNode
	cn.visible = true
	cn.card = card
	cn.setCardVisible(true)
	
	if graveViewing == playerID:
		$GraveDisplay.addCard(card)
	
	
	
	for c in getAllCards():
		c.onGraveAdd(card)

func clearGraveDisplay():
	graveViewing = -1
	$GraveDisplay.clear()

func removeCardFromGrave(playerID : int, index : int):
	graveCards[playerID].remove(index)
	if graveCards[playerID].size() == 0:
		var cn = graves[playerID].cardNode
		cn.visible = false
		cn.setCardVisible(false)
		clearGraveDisplay()
		

func createHoverNode(position : Vector2, parent : Node, text : String, flipped = false):
	var hoverInst = hoverScene.instance()
	hoverInst.flipped = flipped
	parent.add_child(hoverInst)
	hoverInst.global_position = position
	hoverInst.setText(text)
	hoveringWindow = hoverInst

func initZones():
	$GraveDisplay.moveSpeed = 1200
	
	var cardInst = null
	
	#	PLAYER 1 SLOTS  	#
	var p = players[0]
	
	for i in range(p.creatureNum):
		cardInst = cardSlot.instance()
		cardInst.currentZone = CardSlot.ZONES.CREATURE
		cardInst.playerID = p.UUID
		creatures_A_Holder.add_child(cardInst)
		cardInst.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
		creatures[p.UUID].append(cardInst)
		boardSlots.append(cardInst)
	centerNodes(creatures[p.UUID], Vector2(), cardWidth, cardDists)
	
	cardInst = cardSlot.instance()
	cardInst.currentZone = CardSlot.ZONES.DECK
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
	
	
	cardInst = cardSlot.instance()
	cardInst.currentZone = CardSlot.ZONES.GRAVE
	cardInst.playerID = p.UUID
	$GraveHolder.add_child(cardInst)
	cardInst.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
	cardInst.position = Vector2(0, cardHeight + cardDists)
	graves[p.UUID] = cardInst
	graveCards[p.UUID] = []
	cardNodeInst = cardNode.instance()
	cardNodeInst.card = ListOfCards.getCard(0)
	cardNodeInst.cardVisible = true
	cardNodeInst.visible = false
	cardNodeInst.playerID = p.UUID
	$GraveHolder.add_child(cardNodeInst)
	cardNodeInst.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
	cardInst.cardNode = cardNodeInst
	cardNodeInst.position = cardInst.position
	
	
	
	#	PLAYER 2 SLOTS  	#
	p = players[1]
	
	for i in range(p.creatureNum):
		cardInst = cardSlot.instance()
		cardInst.isOpponent = true
		cardInst.currentZone = CardSlot.ZONES.CREATURE
		cardInst.playerID = p.UUID
		creatures_B_Holder.add_child(cardInst)
		cardInst.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
		creatures[p.UUID].append(cardInst)
		boardSlots.append(cardInst)
	centerNodes(creatures[p.UUID], Vector2(), cardWidth, cardDists)
	
	cardInst = cardSlot.instance()
	cardInst.currentZone = CardSlot.ZONES.DECK
	cardInst.isOpponent = true
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
	
	
	cardInst = cardSlot.instance()
	cardInst.currentZone = CardSlot.ZONES.GRAVE
	cardInst.playerID = p.UUID
	$GraveHolder.add_child(cardInst)
	cardInst.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
	cardInst.position = Vector2(0, -cardHeight - cardDists)
	graves[p.UUID] = cardInst
	graveCards[p.UUID] = []
	cardNodeInst = cardNode.instance()
	cardNodeInst.card = ListOfCards.getCard(0)
	cardNodeInst.cardVisible = true
	cardNodeInst.visible = false
	cardNodeInst.playerID = p.UUID
	$GraveHolder.add_child(cardNodeInst)
	cardNodeInst.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
	cardInst.cardNode = cardNodeInst
	cardNodeInst.position = cardInst.position
	
		
func initHands():
	players[0].hand = card_A_Holder
	players[0].initHand()
	players[1].hand = card_B_Holder
	players[1].initHand()
	players[0].hand.deck = decks[players[0].UUID]
	players[1].hand.deck = decks[players[1].UUID]
				
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
	var parent = null
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
	#	yield(get_tree().create_timer(0.02), "timeout")
	
	if parent != null:
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
	if is_instance_valid(slot.cardNode) and slot.cardNode.getCardVisible() and slot.currentZone == CardSlot.ZONES.CREATURE:
		slot.cardNode.addIcons()
		slot.cardNode.iconsShowing = true
	
	if hoveringOn != null:
		onSlotExit(hoveringOn)
	
	hoveringOn = slot
	
	if highlightedSlots.size() > 0:
		for s in highlightedSlots:
			if is_instance_valid(s):
				s.setHighlight(false)
		highlightedSlots.clear()
	
	if cardsHolding.size() > 0:
		var canFuse = true
		
		if (is_instance_valid(slot.cardNode) and not slot.cardNode.getCardVisible()) or slot.currentZone != slot.ZONES.CREATURE:
			canFuse = false
		
		if is_instance_valid(slot.cardNode) and not slot.cardNode.card.canFuseThisTurn:
			canFuse = false
		
		if canFuse:
			var cardsToCheck = []
			if is_instance_valid(slot.cardNode):
				cardsToCheck.append(slot.cardNode.card)
			for s in cardsHolding:
				cardsToCheck.append(s.cardNode.card)
			if not ListOfCards.canFuseCards(cardsToCheck):
				canFuse = false
		
		if canFuse and isMyTurn():
			slot.setHighlight(true)
			highlightedSlots.append(slot)
		
	if slot.playerID != -1:
		if is_instance_valid(selectedCard):
			var opponentHasTaunt = false
			for s in creatures[slot.playerID]:
				if is_instance_valid(s.cardNode) and ListOfCards.hasAbility(s.cardNode.card, AbilityTaunt) and ListOfCards.getAbility(s.cardNode.card, AbilityTaunt).active:
					opponentHasTaunt = true
			
			if isMyTurn() and not opponentHasTaunt or (is_instance_valid(slot.cardNode) and ListOfCards.hasAbility(slot.cardNode.card, AbilityTaunt) and ListOfCards.getAbility(slot.cardNode.card, AbilityTaunt).active):
				if slot.playerID != selectedCard.playerID and slot.currentZone == CardSlot.ZONES.CREATURE:
					if ListOfCards.hasAbility(selectedCard.cardNode.card, AbilityPronged):
						for s in slot.getNeighbors():
							s.setHighlight(true)
							highlightedSlots.append(s)
					else:
						slot.setHighlight(true)
						highlightedSlots.append(slot)
		
	if is_instance_valid(slot) and cardsHolding.size() > 0 and slot.currentZone == CardSlot.ZONES.CREATURE:
		for s in cardsHolding:
			s.cardNode.card.onHoverEnter(slot)


func onSlotExit(slot : CardSlot):
	if is_instance_valid(slot):
		if is_instance_valid(slot.cardNode):
			slot.cardNode.removeIcons()
			slot.cardNode.iconsShowing = false
			
		if slot == hoveringOn:
			if highlightedSlots.size() > 0:
				for s in highlightedSlots:
					if is_instance_valid(s):
						s.setHighlight(false)
				highlightedSlots.clear()
			hoveringOn = null

			if is_instance_valid(slot) and cardsHolding.size() > 0 and slot.currentZone == CardSlot.ZONES.CREATURE:
				for s in cardsHolding:
					s.cardNode.card.onHoverExit(slot)
		

func onMouseDown(slot : CardSlot, button_index : int):
	if gameStarted and not gameOver and button_index == 1:
		if selectingSlot:
			slotClicked(slot, button_index)
		else:
			actionQueue.append([slot, button_index])
	elif button_index == 2:
		rightClickQueue.append(slot)
	
func onMouseUp(Slot : CardSlot, button_index : int):
	pass

func slotClicked(slot : CardSlot, button_index : int, fromServer = false) -> bool:
	if button_index == 1 and selectingSlot:
		if (fromServer or players[0].UUID == selectingUUID):
			selectingSource.slotClicked(slot)
		else:
			return false
	else:
		if not is_instance_valid(slot):
			return false
			
		if gameOver:
			return false
			
		if activePlayer == -1:
			return false
		
		if button_index == 2:
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
							if cardsPerTurn - cardsPlayed - cardsHolding.size() > getCardCost(slot.cardNode.card) - 1:
								if slot.cardNode.card.canBePlayed:
									cardsHolding.append(slot)
									slot.position.y -= cardDists
									slot.cardNode.position.y = slot.position.y
								else:
									if cardsShaking.has(slot):
										MessageManager.notify("This card cannot be played")
									cardsShaking[slot] = shakeMaxTime
									return false
							else:
								if cardsShaking.has(slot):
									MessageManager.notify("You may only play " + str(cardsPerTurn) + " per turn")
								cardsShaking[slot] = shakeMaxTime
								return false
						var cost = 0
						for s in cardsHolding:
							cost += getCardCost(s.cardNode.card)
						if activePlayer == 0:
							$CardsLeftIndicator_A.setCardData(cardsPerTurn - cardsPlayed - cost, cost, cardsPlayed)
						else:
							$CardsLeftIndicator_B.setCardData(cardsPerTurn - cardsPlayed - cost, cost, cardsPlayed)
					else:
						if cardsShaking.has(slot):
							MessageManager.notify("You may only play " + str(cardsPerTurn) + " per turn")
						cardsShaking[slot] = shakeMaxTime
						return false
			elif slot.currentZone == CardSlot.ZONES.CREATURE:
				if cardsHolding.size() > 0 and cardNodesFusing.size() == 0:
					#PUTTING A CREATURE ONTO THE FIELD
					
					if not isMyTurn() and not fromServer:
						return false
					
					if is_instance_valid(slot.cardNode) and not slot.cardNode.card.canFuseThisTurn:
						if cardsShaking.has(slot):
							MessageManager.notify("This creature cannot be fused this turn")
						cardsShaking[slot] = shakeMaxTime
						return false
					##
					var cardsToCheck = []
					if is_instance_valid(slot.cardNode):
						cardsToCheck.append(slot.cardNode.card)
					for s in cardsHolding:
						cardsToCheck.append(s.cardNode.card)
					if not ListOfCards.canFuseCards(cardsToCheck):
						if is_instance_valid(slot.cardNode):
							if cardsShaking.has(slot):
								MessageManager.notify("A creature can have at most two creature types")
							cardsShaking[slot] = shakeMaxTime
						else:
							var shownMessage = false
							for s in cardsHolding:
								if cardsShaking.has(s) and not shownMessage:
									shownMessage = true
									MessageManager.notify("A creature can have at most two creature types")
								cardsShaking[s] = shakeMaxTime
								
						return false
					##
					
					
					if highlightedSlots.size() > 0:
						for s in highlightedSlots:
							if is_instance_valid(s):
								s.setHighlight(false)
						highlightedSlots.clear()
					
					if is_instance_valid(hoveringOn):
						for s in cardsHolding:
							s.cardNode.card.onHoverExit(slot)
					
					var cardList = []
						
					for c in cardsHolding:
						cardList.append(c.cardNode.card)
						
					var cost = 0
					for s in cardsHolding:
						cost += getCardCost(s.cardNode.card)
					cardsPlayed += cost
					
					for c in getAllCards():
						c.onCardsPlayed(slot, cardList)
					
					while cardsHolding.size() > 0:
						var c = cardsHolding[0]
						cardsHolding.remove(0)
						var cardNode = c.cardNode
						cardNode.get_parent().remove_child(cardNode)
						card_A_Holder.nodes.erase(cardNode)
						card_B_Holder.nodes.erase(cardNode)
						if c.currentZone == CardSlot.ZONES.HAND:
							card_A_Holder.slots.erase(c)
							card_B_Holder.slots.erase(c)
							c.queue_free()
					
					fuseToSlot(slot, cardList)

					if activePlayer == 0:
						$CardsLeftIndicator_A.setCardData(cardsPerTurn - cardsPlayed, 0, cardsPlayed)
					else:
						$CardsLeftIndicator_B.setCardData(cardsPerTurn - cardsPlayed, 0, cardsPlayed)
						
				else:
					if not isMyTurn() and not fromServer:
						return false
					if slot.playerID == players[activePlayer].UUID:
						#ATTACKING
						if is_instance_valid(slot) and selectedCard == slot:
							selectedCard.cardNode.rotation = 0
							selectRotTimer = 0
							selectedCard = null
						else:
							if is_instance_valid(slot.cardNode) and slot.cardNode.card.canAttack():
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
							var opponentHasTaunt = false
							for s in creatures[slot.playerID]:
								if is_instance_valid(s.cardNode) and ListOfCards.hasAbility(s.cardNode.card, AbilityTaunt) and ListOfCards.getAbility(s.cardNode.card, AbilityTaunt).active:
									opponentHasTaunt = true
							
							if not opponentHasTaunt or (is_instance_valid(slot.cardNode) and ListOfCards.hasAbility(slot.cardNode.card, AbilityTaunt) and ListOfCards.getAbility(slot.cardNode.card, AbilityTaunt).active):
								var slots = []
								if ListOfCards.hasAbility(selectedCard.cardNode.card, AbilityPronged):
									slots = slot.getNeighbors()
								else:
									slots = [slot]
									
								selectedCard.cardNode.attack(slots)
								if is_instance_valid(selectedCard.cardNode):
									selectedCard.cardNode.rotation = 0
									selectRotTimer = 0
								selectedCard = null
								
								if highlightedSlots.size() > 0:
									for s in highlightedSlots:
										if is_instance_valid(s):
											s.setHighlight(false)
									highlightedSlots.clear()
			
							else:
								if cardsShaking.has(slot):
									MessageManager.notify("A creature with taunt must be attacked first")
								cardsShaking[slot] = shakeMaxTime
								return false
						else:
							return false
							
							
	#CODE IS ONLY REACHABLE IF NOT RETURNED
	dataLog.append(("OWN_" if not fromServer else "OPPONENT_") + "SLOT " + str(slot.isOpponent) + " " + str(slot.currentZone) + " " + str(slot.get_index()))
	if not fromServer:
		Server.slotClicked(opponentID, slot.isOpponent, slot.currentZone, slot.get_index(), button_index)
	
	return true

func fuseToSlot(slot : CardSlot, cards : Array):
	isEntering = not is_instance_valid(slot.cardNode)
	
	if not isEntering:
		if slot == selectedCard:
			selectedCard.cardNode.rotation = 0
			selectRotTimer = 0
			selectedCard = null
		cards.insert(0, slot.cardNode.card)
		slot.cardNode.queue_free()
		slot.cardNode = null
	
	if Settings.playAnimations:
		if slot == hoveringWindowSlot:
			if is_instance_valid(hoveringWindow):
				if hoveringWindow.close(true):
					hoveringWindowSlot = null
		
		while cards.size() > 0:
			var card = cards[0]
			cards.remove(0)
			
			var cn = cardNode.instance()
			cn.card = card
			card.cardNode = cn
			card.playerID = slot.playerID
			
			cardNodesFusing.append(cn)
			cn.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
			cn.z_index = 1
			$Fusion_Holder.add_child(cn)
			cn.position = Vector2()
			card_A_Holder.nodes.erase(cn)
			card_B_Holder.nodes.erase(cn)
		
		for i in range(0 if isEntering else 1, cardNodesFusing.size()):
			addCardToGrave(players[activePlayer].UUID, ListOfCards.getCard(cardNodesFusing[i].card.UUID))
		
		fuseStartPos = cardNodesFusing[0].global_position
		fuseEndSlot = slot
		fuseTimer = 0
		fuseReturnTimer = 0
		
		fuseWaiting = true
		fuseWaitTimer = 0
	else:
		for i in range(0 if isEntering else 1, cards.size()):
			addCardToGrave(players[activePlayer].UUID, ListOfCards.getCard(cards[i].UUID))
		
		var newCard = ListOfCards.fuseCards(cards)
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
			for c in getAllCards():
				if c != newCard:
					c.onOtherEnter(fuseEndSlot)
			newCard.onEnter(fuseEndSlot)
			
		else:
			for c in getAllCards():
				if c != newCard:
					c.onOtherEnterFromFusion(fuseEndSlot)
			newCard.onEnterFromFusion(fuseEndSlot)
		
		checkState()
		
		card_A_Holder.centerCards()
		card_B_Holder.centerCards()
	
	card_A_Holder.centerCards()
	card_B_Holder.centerCards()
	centerNodes($Fusion_Holder.get_children(), Vector2(), cardWidth, cardDists)

func isMyTurn() -> bool:
	return 0 == activePlayer

func passMyTurn():
	if isMyTurn():
		if not get_node("/root/main/CenterControl/PauseNode/PauseMenu").visible and not get_node("/root/main/CenterControl/FileSelector").visible:
			if not gameOver and gameStarted:
				var waiting = true
				while waiting:
					waiting = getWaiting()
							
					yield(get_tree().create_timer(0.1), "timeout")
				
				if isMyTurn():
					nextTurn()
					Server.onNextTurn(opponentID)

func isDrawing() -> bool:
	for p in players:
		if p.hand.drawQueue.size() > 0:
			return true
	return false

func getWaiting() -> bool:
	
	var waiting = false
	for slot in creatures[players[activePlayer].UUID]:
		if is_instance_valid(slot.cardNode) and slot.cardNode.attacking:
			waiting = true
			
	for p in players:
		if p.hand.drawQueue.size() > 0:
			waiting = true
	
	if cardNodesFusing.size() > 0:
		waiting = true
				
	if millQueue.size() > 0:
		waiting = true
			
	if actionQueue.size() > 0:
		waiting = true
		
	if abilityStack.size() > 0:
		waiting = true
	
	return waiting
	

var clickedOff = false
func _input(event):
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.scancode == KEY_F1:
			saveReplay()
	
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.scancode == KEY_SPACE:
			passMyTurn()
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == 2:
		clickedOff = true

func isOnBoard(card : Card):
	for i in range(players.size()):
		var p = players[(activePlayer + i) % players.size()]
		for s in creatures[p.UUID]:
			if is_instance_valid(s.cardNode) and s.cardNode.card == card:
				return true
	return false

func getCardCost(card) -> int:
	var cost = 1
	
	cost += card.onAdjustCost(card, cost)
	
	var crs = getAllCreatures()
	crs.invert()
	for c in crs:
		cost += c.onAdjustCost(card, cost)
	
	return cost

func getAllCards() -> Array:
	var cards := []
	for i in range(players.size()):
		var p = players[(activePlayer + i) % players.size()]
		
		for s in p.hand.slots:
			if is_instance_valid(s.cardNode):
				cards.append(s.cardNode.card)
		for s in creatures[p.UUID]:
			if is_instance_valid(s.cardNode):
				cards.append(s.cardNode.card)
		for cn in cardNodesFusing:
			cards.append(cn.card)
	
	cards.invert()
	return cards

func getAllPlayers() -> Array:
	var pl := []
	for i in range(players.size()):
		var p = players[(activePlayer + i) % players.size()]
		pl.append(p)
	return pl

func getAllCreatures() -> Array:
	var cards := []
	for p in getAllPlayers():
		for s in creatures[p.UUID]:
			if is_instance_valid(s.cardNode):
				cards.append(s.cardNode.card)
	cards.invert()
	return cards

func nextTurn():
	if gameOver:
		return
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
	for c in getAllCards():
		c.onEndOfTurn()
	######################
	
	while abilityStack.size() > 0:
		yield(get_tree().create_timer(0.1), "timeout")
	
	cardsPlayed = 0
	activePlayer = (activePlayer + 1) % players.size()
	setTurnText()
	players[activePlayer].hand.drawCard()
	cardsPerTurn = cardsPerTurnMax
		
	if activePlayer == 0:
		$CardsLeftIndicator_A.setCardData(cardsPerTurn - cardsPlayed, 0, cardsPlayed)
	else:
		$CardsLeftIndicator_B.setCardData(cardsPerTurn - cardsPlayed, 0, cardsPlayed)
		
	######################	ON START OF TURN EFFECTS
	for c in getAllCards():
		c.onStartOfTurn()
	######################

func checkState():
	var boardState = []
	var slots = []
	for p in getAllPlayers():
		for s in creatures[p.UUID]:
			if is_instance_valid(s.cardNode):
				boardState.append(s.cardNode.card.serialize())
			else:
				boardState.append({})
	
	var creaturesDying = []
	for p in getAllPlayers():
		for s in creatures[p.UUID]:
			if is_instance_valid(s.cardNode):
				if s.cardNode.card.toughness <= 0:
					creaturesDying.append(s.cardNode)
				
	for cardNode in creaturesDying:
		if hoveringWindowSlot == cardNode.slot:
			hoveringWindow.close(true)
			hoveringWindowSlot = null
		
		
		cardNode.card.onLeave()
		cardNode.card.onDeath()
		
		for c in getAllCards():
			if c != cardNode.card:
				c.onOtherLeave(cardNode.slot)
				c.onOtherDeath(cardNode.slot)
		if cardNode.card.toughness <= 0:
			cardNode.slot.cardNode = null
			cardNode.queue_free()

	var boardStateNew = []
	for p in getAllPlayers():
		for s in creatures[p.UUID]:
			if is_instance_valid(s.cardNode):
				boardStateNew.append(s.cardNode.card.serialize())
			else:
				boardStateNew.append({})
				
	for i in range(boardState.size()):
		if not Card.areIdentical(boardState[i], boardStateNew[i]):
			#yield(get_tree().create_timer(0.1), "timeout")
			checkState()

func getSlot(source, selectingUUID : int):
	selectingSlot = true
	selectingSource = source
	self.selectingUUID = selectingUUID
	stackTimer = 0

func endGetSlot():
	selectingSlot = false
	selectingSource = null
	abilityStack.remove(0)
	if abilityStack.size() > 0:
		stackTimer = stackMaxTime
	currentAbility = null
	checkState()

func onLoss(player : Player):
	if not gameOver and not deadPlayers.has(player):
		deadPlayers.append(player)

func setOwnUsername():
	print("Settings own username")
	$UsernameLabel.text = Server.username
	dataLog.append("SET_OWN_USERNAME " + Server.username)

func setOpponentUsername(username : String):
	print("Settings opponent username")
	$UsernameLabel2.text = username
	dataLog.append("SET_OPPONENT_USERNAME " + username)

func editOwnName(username):
	setOwnUsername()

func editPlayerName(player_id : int, username : String):
	if player_id == opponentID:
		setOpponentUsername(username)

var dataLog := []

func saveReplay():
	FileIO.dumpDataLog(dataLog)
