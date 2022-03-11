extends DraftClass

var numStacks = 3
var numCards = 30

var currentPlayer : int = -1
var playerIDs : Array = []

var currentIndex : int = 0
var cardDisplaySlots := []

var mainSlot : CardSlot
var mainStack := []
var stacks := []

var slots := []

var hoveringWindow
var hoveringSlot

var cardSlot = preload("res://Scenes/CardSlot.tscn")
var cardNode = preload("res://Scenes/CardNode.tscn")
var hoverScene = preload("res://Scenes/UI/Hover.tscn")
var fadingScene = preload("res://Scenes/UI/FadingNode.tscn")
var popupUI = preload("res://Scenes/UI/PopupUI.tscn")
var fontTRES = preload("res://Fonts/FontNormal.tres")

var cardDists = 16
onready var cardWidth = ListOfCards.cardBackground.get_width()
onready var cardHeight = ListOfCards.cardBackground.get_height()

func _ready():
	$CardDisplay.board = self
	
	for i in range(numStacks):
		var cardInst = cardSlot.instance()
		cardInst.board = self
		slots.append(cardInst)
		$CardHolder.add_child(cardInst)
		cardInst.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
		
	BoardMP.centerNodes(slots, Vector2(-cardWidth - cardDists, cardHeight * Settings.cardSlotScale * 0.75), cardWidth, cardDists)
	
	mainSlot = cardSlot.instance()
	mainSlot.board = self
	$CardHolder.add_child(mainSlot)
	mainSlot.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
	mainSlot.position = slots[slots.size() - 1].position + Vector2(cardWidth * 2 * Settings.cardSlotScale, 0)
		
	var mainNode = cardNode.instance()
	mainNode.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
	mainNode.setCardVisible(false)
	$CardHolder.add_child(mainNode)
	mainNode.position = mainSlot.position
	mainSlot.cardNode = mainNode
	mainNode.slot = mainSlot
	
	for i in range(slots.size()):
		stacks.append([])
		
	if Server.host:
		var gameSeed = OS.get_system_time_msecs()
		print("current game seed is ", gameSeed)
		seed(gameSeed)
	
		playerIDs = Server.playerIDs.duplicate()
		playerIDs.append(1)
		playerIDs.shuffle()
		
		for i in range(numCards * playerIDs.size()):
			var card : Card
			while card == null or card.tier > 1:
				var index = randi() % ListOfCards.cardList.size()
				card = ListOfCards.getCard(index)
			mainStack.append(card)
		
		var cardIDs : Array = []
		for c in mainStack:
			cardIDs.append(c.UUID)
		
		Server.sendDraftData(cardIDs, playerIDs)
		
		for i in range(slots.size()):
			addCardToStack(i)
		
		addAllPlayerDisplay()
		
		nextPlayer()

func closeDraft():
	Server.closeServer()
	var error = get_tree().change_scene("res://Scenes/StartupScreen.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))
	

func setDraftData(cardIDs : Array, draftOrder : Array):
	for i in cardIDs:
		mainStack.append(ListOfCards.getCard(i))
	playerIDs = draftOrder
	
	addAllPlayerDisplay()

func startPick():
	currentIndex = 0
	revealCards(currentIndex)

func addCardToStack(index : int, fromServer = false):
	var card = mainStack.pop_front()
	if card != null:
		var node = cardNode.instance()
		node.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
		node.card = card
		node.setCardVisible(false)
		$CardHolder.add_child(node)
		node.position = slots[index].position
		stacks[index].append(node)
	else:
		if is_instance_valid(mainSlot.cardNode):
			mainSlot.cardNode.queue_free()
			mainSlot.cardNode = null
	
	if not fromServer:
		Server.addCardToStack(index)
	
	if hoveringSlot == slots[index]:
		hoveringWindow.get_node("Label").text = str(stacks[index].size())

func revealCards(index : int):
	if stacks[index].size() == 0:
		onLeaveButtonPressed()
	
	$TakeButton.visible = true
	$LeaveButton.visible = true
	
	for i in range(stacks[index].size()):
		var slot = cardSlot.instance()
		slot.board = self
		$CardHolder.add_child(slot)
		slot.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
		cardDisplaySlots.append(slot)
		slot.get_node("SpotSprite").visible = false
		
		stacks[index][i].setCardVisible(true)
		
		slot.cardNode = stacks[index][i]
		stacks[index][i].slot = slot
		
	BoardMP.centerNodes(cardDisplaySlots, Vector2(0, -cardHeight * Settings.cardSlotScale * 0.75), cardWidth, cardDists)
	BoardMP.centerNodes(stacks[index], Vector2(0, -cardHeight * Settings.cardSlotScale * 0.75), cardWidth, cardDists)

func returnCards():
	while cardDisplaySlots.size() > 0:
		if hoveringSlot == cardDisplaySlots[0]:
			closeHoverNode()
		
		cardDisplaySlots[0].queue_free()
		cardDisplaySlots.remove(0)
	
	for i in range(stacks[currentIndex].size()):
		stacks[currentIndex][i].setCardVisible(false)
		stacks[currentIndex][i].position = slots[currentIndex].position

func closeHoverNode():
	hoveringSlot = null
	hoveringWindow.close()

func createHoverNode(position : Vector2, text : String):
	var hoverInst = hoverScene.instance()
	$CardHolder.add_child(hoverInst)
	hoverInst.global_position = position
	hoverInst.setText(text)
	hoveringWindow = hoverInst

func onTakeButtonPressed():
	$TakeButton.visible = false
	$LeaveButton.visible = false
	
	for i in range(stacks[currentIndex].size()):
		$CardDisplay.addCard(stacks[currentIndex][i].card)
	
	while cardDisplaySlots.size() > 0:
		if hoveringSlot == cardDisplaySlots[0]:
			closeHoverNode()
			
		cardDisplaySlots[0].queue_free()
		cardDisplaySlots.remove(0)
	clearStack(currentIndex)
	addCardToStack(currentIndex)
	checkEnded()

func showHideButtonPressed():
	$CardDisplay.visible = !$CardDisplay.visible
	if $ShowHideButton.text == "Show Cards":
		$ShowHideButton.text = "Hide Cards"
	else:
		$ShowHideButton.text = "Show Cards"

func clearStack(index : int, fromServer = false):
	if not fromServer:
		Server.clearStack(index)
	while stacks[index].size() > 0:
		stacks[index][0].queue_free()
		stacks[index].remove(0)
	
	if hoveringSlot == slots[index]:
		hoveringWindow.get_node("Label").text = str(stacks[index].size())

func onLeaveButtonPressed():
	$TakeButton.visible = false
	$LeaveButton.visible = false
	
	returnCards()
	addCardToStack(currentIndex)
		
	if currentIndex < numStacks - 1:
		currentIndex += 1
		revealCards(currentIndex)
	else:
		var card = mainStack.pop_front()
		if card != null:
			Server.popMainStack()
			$CardDisplay.addCard(card)
		else:
			if is_instance_valid(mainSlot.cardNode):
				mainSlot.cardNode.queue_free()
				mainSlot.cardNode = null
		checkEnded()

func checkEnded():
	var isEnd = true
	for i in range(stacks.size()):
		if stacks[i].size() > 0:
			isEnd = false
	
	if isEnd:
		Server.startBuilding()
	else:
		nextPlayer()

var idToDisplayLabel : Dictionary = {}

func addAllPlayerDisplay():
	for player_id in playerIDs:
		var uname
		if not Server.playerIDs.has(player_id):
			uname = Server.username
		else:
			uname = Server.playerNames[player_id]
		addPlayerDisplay(uname, player_id)

func addPlayerDisplay(username : String, player_id : int):
	var label = Label.new()
	label.text = username
	label.set("custom_colors/font_color", Color(0,0,0))
	label.set("custom_fonts/font", fontTRES)
	$OrderDisplay/VBoxContainer.add_child(label)
	
	idToDisplayLabel[player_id] = label

func playerDisconnected(player_id):
	if idToDisplayLabel.has(player_id):
		MessageManager.notify("User " + str(player_id) + " disconnected")
		
		var c = idToDisplayLabel[player_id]
		idToDisplayLabel.erase(player_id)
		$OrderDisplay/VBoxContainer.remove_child(c)
		c.queue_free()
		
		var isCurrent = false
		if Server.host:
			isCurrent = playerIDs[currentPlayer] == player_id
		playerIDs.erase(player_id)
		if Server.host:
			if isCurrent:
				currentPlayer -= 1
				nextPlayer()
			else:
				setCurrentPlayerDisplay(currentPlayer)
		

func nextPlayer():
	if Server.host:
		var nextPlayerIndex = (currentPlayer + 1) % playerIDs.size()
		
		setCurrentPlayerDisplay(nextPlayerIndex)
		Server.setCurrentPlayerDisplay(nextPlayerIndex)
		
		currentPlayer = nextPlayerIndex
		
		if playerIDs[currentPlayer] == 1:
			startPick()
		else:
			Server.startPick(playerIDs[currentPlayer])
		
	else:
		Server.nextPlayer()

func setCurrentPlayerDisplay(currentPlayer):
	yield(get_tree().create_timer(0.02), "timeout")
	
	var extra = Vector2(4, 4)
	
	var player_id = playerIDs[currentPlayer]
	$OrderDisplay/ReferenceRect.rect_global_position = idToDisplayLabel[player_id].rect_global_position - extra
	$OrderDisplay/ReferenceRect.rect_size = idToDisplayLabel[player_id].rect_size + extra * 2

var slotClickedQueue := []

func _physics_process(delta):
	if slotClickedQueue.size() > 0:
		var highestZ = slotClickedQueue[0]
		for i in range(1, slotClickedQueue.size()):
			if not is_instance_valid(highestZ.cardNode) or (is_instance_valid(slotClickedQueue[i].cardNode) and slotClickedQueue[i].cardNode.z_index > highestZ.cardNode.z_index):
				highestZ = slotClickedQueue[i]
		
		#CHECK FOR STACKS
		
		var isSame = hoveringSlot == highestZ
		if is_instance_valid(hoveringWindow):
			closeHoverNode()
		
		if highestZ == mainSlot:
			#DISPLAY THE SIZE OF THE MAIN STACK
			if not isSame:
				var numCards = mainStack.size()
				var pos = highestZ.global_position + Vector2(cardWidth * 3.0/5, 0)
				createHoverNode(pos, str(numCards))
				hoveringSlot = highestZ
		else:
			#DISPLAY THE SIZE OF THE STACK
			var index = slots.find(highestZ)
			if index >= 0:
				if not isSame:
					var numCards = stacks[index].size()
					var pos = highestZ.global_position + Vector2(cardWidth * 3.0/5, 0)
					createHoverNode(pos, str(numCards))
					hoveringSlot = highestZ
			else:
				if not isSame:
					var pos = highestZ.global_position + Vector2(cardWidth * 3.0/5 * Settings.cardSlotScale, 0)
					createHoverNode(pos, highestZ.cardNode.card.getHoverData())
					hoveringSlot = highestZ
					
		slotClickedQueue.clear()

func quitButtonPressed():
	var pop = popupUI.instance()
	pop.init("Quit Draft", "Are you sure you want to quit? There will be no way to return", [["Yes", self, "closeDraft", []], ["Back", pop, "close", []]])
	$CardHolder.add_child(pop)

func onSlotBeingClicked(slot : CardSlot, buttonIndex):
	if buttonIndex == 2:
		slotClickedQueue.append(slot)

func onSlotEnter(slot : CardSlot):
	pass
	
func onSlotExit(slot : CardSlot):
	pass

