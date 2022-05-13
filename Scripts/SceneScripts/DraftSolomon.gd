extends DraftClass

class_name DraftSolomon

var boosterCount : int = 0
var numBoosters : int = 0
var opponentID : int = -1
var cardsPerBooster : int = 10

var popupUI = preload("res://Scenes/UI/PopupUI.tscn")
var cardNodeScene = preload("res://Scenes/CardNode.tscn")

var hoveringWindow
var hoveringSlot
var hoverScene = preload("res://Scenes/UI/Hover.tscn")

var cardDists = 16
onready var cardWidth = ListOfCards.cardBackground.get_width()
onready var cardHeight = ListOfCards.cardBackground.get_height()

enum STATES {WAITING, MOVING, CHOOSING}
var currentState = -1
var opponentState = -1

func _ready():
	var gameSeed = OS.get_system_time_msecs()
	print("current game seed is ", gameSeed)
	seed(gameSeed)
	
	opponentID = Server.playerIDs[0]
	
	$DeckDisplayControl/DeckDisplay.parent = self
	
	
	setCurrentState(STATES.WAITING)
	if Server.host:
		if randi() % 2 == 0:
			genNewBooster()
		else:
			Server.solomonStart(opponentID)

func genNewBooster():
	$BoosterDisplay/Button.visible = false
	$BoosterDisplay2/Button.visible = false
		
	if boosterCount == numBoosters:
		Server.startSolomonBuilding(opponentID)
	else:
		boosterCount += 1
		$BoosterNum.text = "Booster: (" + str(boosterCount) + "/" + str(numBoosters) + ")"
		
		var cards = []
		while cards.size() != cardsPerBooster:
			var card = ListOfCards.generateCard()
			if card.tier == 1:
				cards.append(card.UUID)
	
		$BoosterDisplay.clear()
		$BoosterDisplay2.clear()
		
		setCards(cards, true)
		sendCards(cards, true)
		
		$BoosterDisplay/SendButton.visible = true
		setCurrentState(STATES.MOVING)
		

func setParams(params : Dictionary):
	if params.has("num_boosters"):
		numBoosters = params["num_boosters"]

func onSlotEnter(slot : CardSlot):
	pass
	
func onSlotExit(slot : CardSlot):
	pass

func closeDraft():
	Server.closeServer()
	
	var error = get_tree().change_scene("res://Scenes/StartupScreen.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))

func playerDisconnected(player_id):
	return
	if player_id == opponentID:
		Server.closeServer()

func setDraftData(data : Array):
	pass

func onQuitButtonPressed():
	var pop = popupUI.instance()
	if Input.is_key_pressed(KEY_CONTROL):
		pop.init("DEBUG_QUIT", "Go to Deck Editor?", [["Yes", Server, "receivedStartBuilding", []], ["Back", pop, "close", []]])
	else:
		pop.init("Quit Draft", "Are you sure you want to quit? There will be no way to return", [["Yes", self, "closeDraft", []], ["Back", pop, "close", []]])
	$CenterControl.add_child(pop)

func onSettingsPressed():
	$SettingsHolder/SettingsPage.visible = true

var slotClickedQueue1 := []
var slotClickedQueue2 := []
var clickedOff = false

var doubleClickSlot = null
var doubleClickTimer = 0
var doubleClickMaxTime = 0.2

func onMouseDown(slot : CardSlot, button_index : int):
	if button_index == 1:
		if currentState == STATES.MOVING or $CardDisplay.slots.has(slot):
			slotClickedQueue1.append(slot)
		
	if button_index == 2:
		slotClickedQueue2.append(slot)

func _physics_process(delta):
	
	if slotClickedQueue1.size() > 0:
		var highestZ = slotClickedQueue1[0]
		for i in range(1, slotClickedQueue1.size()):
			if not is_instance_valid(highestZ.cardNode) or (is_instance_valid(slotClickedQueue1[i].cardNode) and slotClickedQueue1[i].cardNode.z_index > highestZ.cardNode.z_index):
				highestZ = slotClickedQueue1[i]
		slotClickedQueue1.clear()
		
		if $BoosterDisplay.slots.has(highestZ):
			if currentState == STATES.MOVING:
				Server.solomonSlotClicked(opponentID, 1, highestZ.get_index())
			
			var node = highestZ.cardNode
			$BoosterDisplay.slots.erase(highestZ)
			$BoosterDisplay.nodes.erase(highestZ.cardNode)
			$BoosterDisplay2.addCardNode(node, true)
			$BoosterDisplay.centerCards()
			$BoosterDisplay2.centerCards()
			highestZ.queue_free()
			SoundEffectManager.playDrawSound()
			
		elif $BoosterDisplay2.slots.has(highestZ):
			if currentState == STATES.MOVING:
				Server.solomonSlotClicked(opponentID, 2, highestZ.get_index())
			var node = highestZ.cardNode
			$BoosterDisplay2.slots.erase(highestZ)
			$BoosterDisplay2.nodes.erase(highestZ.cardNode)
			$BoosterDisplay.addCardNode(node, true)
			$BoosterDisplay.centerCards()
			$BoosterDisplay2.centerCards()
			highestZ.queue_free()
			SoundEffectManager.playDrawSound()
			
			
		elif $CardDisplay.slots.has(highestZ):
			if is_instance_valid(doubleClickSlot) and doubleClickSlot == highestZ:
				$DeckDisplayControl/DeckDisplay.addCard(highestZ.cardNode.card.UUID)
				$CardDisplay.slots.erase(highestZ)
				$CardDisplay.nodes.erase(highestZ.cardNode)
				highestZ.cardNode.queue_free()
				highestZ.queue_free()
				$CardDisplay.centerCards()
			else:
				doubleClickSlot = highestZ
		
	
	if slotClickedQueue2.size() > 0:
		var highestZ = slotClickedQueue2[0]
		for i in range(1, slotClickedQueue2.size()):
			if not is_instance_valid(highestZ.cardNode) or (is_instance_valid(slotClickedQueue2[i].cardNode) and slotClickedQueue2[i].cardNode.z_index > highestZ.cardNode.z_index):
				highestZ = slotClickedQueue2[i]
		slotClickedQueue2.clear()
		
		var isSame = highestZ == hoveringSlot
		closeHoverWindow(true)
			
		if not isSame:
			var pos = highestZ.global_position + Vector2(cardWidth * 3.0/5 * Settings.cardSlotScale, 0)
			createHoverNode(pos, highestZ.cardNode.card.getHoverData())
			hoveringSlot = highestZ
		
	elif clickedOff:
		closeHoverWindow()
	
	clickedOff = false

func editOwnName(username : String):
	$PlayerState.text = username + ": " + stateToText(currentState)

func editPlayerName(player_id : int, username : String):
	$OpponentState.text = username + ": " + stateToText(opponentState)

func stateToText(state : int) -> String:
	match state:
		STATES.WAITING:
			return 'Waiting'
		STATES.MOVING:
			return "Splitting"
		STATES.CHOOSING:
			return "Selecting Stack"
	return "uh-oh"

func createHoverNode(position : Vector2, text : String):
	var hoverInst = hoverScene.instance()
	hoverInst.z_index = 100
	$CenterControl.add_child(hoverInst)
	hoverInst.global_position = position
	hoverInst.setText(text)
	hoveringWindow = hoverInst

func closeHoverWindow(forceClose = false):
	if is_instance_valid(hoveringWindow):
		if hoveringWindow.close(forceClose):
			hoveringSlot = null

func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == 2:
		clickedOff = true

func removeCard(cardUUID : int):
	$CardDisplay.addCard(ListOfCards.getCard(cardUUID))

func sendCardsPressed():
	$BoosterDisplay/SendButton.visible = false
	setCurrentState(STATES.WAITING)
	Server.doneSplitting(opponentID)

func sendCards(dataOverride = null, withFlourish = false):
	var cards
	if dataOverride != null:
		cards = dataOverride
	else:
		cards = [[], []]
		for n in $BoosterDisplay.nodes:
			cards[0].append(n.card.UUID)
		for n in $BoosterDisplay2.nodes:
			cards[1].append(n.card.UUID)
	Server.sendSolomonCards(opponentID, cards, withFlourish)

func setCards(cards : Array, withFlourish = false):
	if withFlourish:
		for cID in cards:
			var node = cardNodeScene.instance()
			node.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
			node.card = ListOfCards.getCard(cID)
			node.setCardVisible(false)
			add_child(node)
			node.global_position = $BoosterDisplay2.rect_global_position
			$BoosterDisplay2.addCardNode(node, true)
			
		yield(get_tree().create_timer(0.1), "timeout")
		for node in $BoosterDisplay2.nodes.duplicate():
			yield(get_tree().create_timer(0.05), "timeout")
			node.flip()
			SoundEffectManager.playDrawSound()
	else:
		var cardsA = []
		var cardsB = []
		for cid in cards[0]:
			cardsA.append(ListOfCards.getCard(cid))
		for cid in cards[1]:
			cardsB.append(ListOfCards.getCard(cid))
		$BoosterDisplay.setCards(cardsA)
		$BoosterDisplay2.setCards(cardsB)

func opponentDoneSplitting():
	$BoosterDisplay/Button.visible = true
	$BoosterDisplay2/Button.visible = true
	setCurrentState(STATES.CHOOSING)

func takeCards1Pressed():
	setCurrentState(STATES.WAITING)
	$BoosterDisplay/Button.visible = true
	$BoosterDisplay2/Button.visible = true
	
	clientTakeStack(1)
	
	Server.takeSolomonStack(opponentID, 2)
	
	genNewBooster()

func takeCards2Pressed():
	setCurrentState(STATES.WAITING)
	$BoosterDisplay/Button.visible = true
	$BoosterDisplay2/Button.visible = true
	
	clientTakeStack(2)
	
	Server.takeSolomonStack(opponentID, 1)
	
	genNewBooster()

func takeSolomonStack(stackNum : int):
	clientTakeStack(stackNum)

func clientTakeStack(stackNum : int):
	var stackTaken
	var stackClear
	if stackNum == 1:
		stackTaken = $BoosterDisplay
		stackClear = $BoosterDisplay2
	elif stackNum == 2:
		stackTaken = $BoosterDisplay2
		stackClear = $BoosterDisplay
	
	for s in stackTaken.slots:
		s.queue_free()
	stackTaken.slots.clear()
	for n in stackTaken.nodes:
		$CardDisplay.addCardNode(n, true)
	stackTaken.nodes.clear()
	stackClear.clear()

func opponentSlotClicked(cardDisplayInt : int, cardIndex : int):
	var cd
	if cardDisplayInt == 1:
		cd = $BoosterDisplay
	elif cardDisplayInt == 2:
		cd = $BoosterDisplay2
	
	slotClickedQueue1.append(cd.get_child(cardIndex))

func setCurrentState(newState : int):
	currentState = newState
	Server.solomonSetState(opponentID, newState)
	editOwnName(SilentWolf.Auth.logged_in_player)

func setOpponentState(newState : int):
	opponentState = newState
	editPlayerName(opponentID, Server.playerNames[opponentID])
