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

var doubleClickSlot = null
var doubleClickTimer = 0
var doubleClickMaxTime = 0.2

var activePlayer = false

#[Node, timer, start pos, end pos, remove when done, timescale]
var movingData := []
var movingMaxTime = 0.35

var processQueue := []


func _ready():
	$DeckDisplayControl/DeckDisplay.parent = self
	$CardDisplay.canReorder = true
	
	for i in range(numStacks):
		var cardInst = cardSlot.instance()
		slots.append(cardInst)
		$CardHolder.add_child(cardInst)
		cardInst.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
		
	BoardMP.centerNodes(slots, Vector2(0, cardHeight * Settings.cardSlotScale * 0.75), cardWidth, cardDists)
	
	mainSlot = cardSlot.instance()
	$CardHolder.add_child(mainSlot)
	mainSlot.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
	mainSlot.position = Vector2(0, -cardHeight)
		
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
			mainStack.append(ListOfCards.generateCard())
		
		var cardIDs : Array = []
		for c in mainStack:
			cardIDs.append(c.UUID)
		
		Server.sendDraftData([cardIDs, playerIDs])
		
		for i in range(slots.size()):
			addCardToStack(i)
		
		addAllPlayerDisplay()
		
		nextPlayer()

func closeDraft():
	Server.closeServer()
	var error = get_tree().change_scene("res://Scenes/StartupScreen.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))
	

func setDraftData(data : Array):
	for i in data[0]:
		mainStack.append(ListOfCards.getCard(i))
	playerIDs = data[1]
	
	addAllPlayerDisplay()

func startPick():
	activePlayer = true
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
		node.position = mainSlot.position
		movingData.append([node, 0, mainSlot.global_position, slots[index].global_position, false, 1])
		stacks[index].append(node)
	else:
		if is_instance_valid(mainSlot.cardNode):
			mainSlot.cardNode.queue_free()
			mainSlot.cardNode = null
	
	if not fromServer:
		Server.addCardToStack(index)
	
	if hoveringSlot == slots[index]:
		hoveringWindow.get_node("Label").text = str(stacks[index].size())
	elif hoveringSlot == mainSlot:
		hoveringWindow.get_node("Label").text = str(mainStack.size())

func revealCards(index : int):
	SoundEffectManager.playDrawSound()
	
	if stacks[index].size() == 0:
		onLeaveButtonPressed()
	
	
	$TakeLeaveCenter/ButtonZ/TakeButton.visible = true
	$TakeLeaveCenter/ButtonZ/LeaveButton.visible = true
	
	for i in range(stacks[index].size()):
		var slot = cardSlot.instance()
		$CardHolder.add_child(slot)
		slot.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
		cardDisplaySlots.append(slot)
		slot.get_node("SpotSprite").visible = false
		
		stacks[index][i].setCardVisible(true)
		
		slot.cardNode = stacks[index][i]
		stacks[index][i].slot = slot
		
		stacks[index][i].z_index += 2
	
	var y = -cardHeight * Settings.cardSlotScale
	BoardMP.centerNodes(cardDisplaySlots, Vector2(0, y), cardWidth, cardDists)
	BoardMP.centerNodes(stacks[index], Vector2(0, y), cardWidth, cardDists)
	
	for i in range(stacks[index].size()):
		var positionOld = slots[index].global_position
		var toRemove := []
		for j in range(movingData.size()):
			if movingData[j][0] == stacks[index][i]:
				positionOld = movingData[j][0].global_position
				toRemove.append(movingData[j])
		for d in toRemove:
			movingData.erase(d)
				
		movingData.append([stacks[index][i], 0, positionOld, stacks[index][i].global_position, false, 1])
		stacks[index][i].global_position = positionOld

func returnCards():
	while cardDisplaySlots.size() > 0:
		if hoveringSlot == cardDisplaySlots[0]:
			closeHoverWindow(true)
		
		cardDisplaySlots[0].queue_free()
		cardDisplaySlots.remove(0)
	
	for i in range(stacks[currentIndex].size()):
		stacks[currentIndex][i].z_index -= 2
		stacks[currentIndex][i].setCardVisible(false)
		stacks[currentIndex][i].position = slots[currentIndex].position

func createHoverNode(position : Vector2, text : String):
	var hoverInst = hoverScene.instance()
	$CardHolder.add_child(hoverInst)
	hoverInst.global_position = position
	hoverInst.setText(text)
	hoveringWindow = hoverInst

func closeHoverWindow(forceClose = false):
	if is_instance_valid(hoveringWindow):
		if hoveringWindow.close(forceClose):
			hoveringSlot = null

func onTakeButtonPressed():
	if movingData.size() == 0:
		SoundEffectManager.playDrawSound()
		
		$TakeLeaveCenter/ButtonZ/TakeButton.visible = false
		$TakeLeaveCenter/ButtonZ/LeaveButton.visible = false
		
		for i in range(stacks[currentIndex].size()):
			var nodeNew = cardNode.instance()
			nodeNew.card = stacks[currentIndex][i].card
			$CardHolder.add_child(nodeNew)
			nodeNew.position = stacks[currentIndex][i].position
			nodeNew.scale = stacks[currentIndex][i].scale
			$CardDisplay.addCardNode(nodeNew, true)
			
			if hoveringSlot == stacks[currentIndex][i]:
				closeHoverWindow(true)
			cardDisplaySlots.erase(stacks[currentIndex][i])
		
		
		while cardDisplaySlots.size() > 0:
			if hoveringSlot == cardDisplaySlots[0]:
				closeHoverWindow(true)
			
			cardDisplaySlots[0].queue_free()
			cardDisplaySlots.remove(0)
		
		clearStack(currentIndex)
		addCardToStack(currentIndex)
		checkEnded()

func clearStack(index : int, fromServer = false):
	
	if not activePlayer:
		for i in range(stacks[index].size()):
			var node = cardNode.instance()
			node.setCardVisible(false)
			$CardHolder.add_child(node)
			node.position = slots[index].position
			node.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
			
			movingData.append([node, (i-stacks[index].size()) / 30.0, node.global_position, node.global_position - Vector2(0, 500), true, 0.3])
	
	if not fromServer:
		Server.clearStack(index)
	while stacks[index].size() > 0:
		stacks[index][0].queue_free()
		stacks[index].remove(0)
	
	if hoveringSlot == slots[index]:
		hoveringWindow.get_node("Label").text = str(stacks[index].size())

func onLeaveButtonPressed():
	if movingData.size() == 0:
		$TakeLeaveCenter/ButtonZ/TakeButton.visible = false
		$TakeLeaveCenter/ButtonZ/LeaveButton.visible = false
		
		returnCards()
		addCardToStack(currentIndex)
			
		if currentIndex < numStacks - 1:
			currentIndex += 1
			revealCards(currentIndex)
		else:
			var card = mainStack.pop_front()
			if card != null:
				SoundEffectManager.playDrawSound()
				Server.popMainStack()
				var cn = $CardDisplay.addCard(card)
				cn.global_position = mainSlot.global_position
				cn.slot.global_position = mainSlot.global_position
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

func editOwnName(username : String):
	editPlayerName(get_tree().get_network_unique_id(), username)

func editPlayerName(player_id : int, username : String):
	idToDisplayLabel[player_id].text = username
	setCurrentPlayerDisplay(currentPlayer)

func playerDisconnected(player_id):
	if idToDisplayLabel.has(player_id):
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
	activePlayer = false
	
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
	self.currentPlayer = currentPlayer
	yield(get_tree().create_timer(0.02), "timeout")
	
	var extra = Vector2(4, 4)
	
	var player_id = playerIDs[self.currentPlayer]
	$OrderDisplay/ReferenceRect.rect_global_position = idToDisplayLabel[player_id].rect_global_position - extra
	$OrderDisplay/ReferenceRect.rect_size = idToDisplayLabel[player_id].rect_size + extra * 2

var slotClickedQueue1 := []
var slotClickedQueue2 := []
var clickedOff = false

func _physics_process(delta):
	
	if movingData.size() > 0:
		var toRemove = []
		for data in movingData:
		#if true:
		#	var data = movingData[0]
			if is_instance_valid(data[0]):
				var t = min(max(data[1] / movingMaxTime, 0), 1)
				var pos = lerp(data[2], data[3], t)
				data[0].global_position = pos
				data[1] += delta * data[5]
				if data[1] >= movingMaxTime:
					toRemove.append(data)
			else:
				toRemove.append(data)
				
		if toRemove.size() > 0:
			for data in toRemove:
				if is_instance_valid(data[0]):
					data[0].global_position = data[3]
					if data[4]:
						data[0].queue_free()
				movingData.erase(data)
	
	if doubleClickSlot != null:
		doubleClickTimer += delta
		if doubleClickTimer >= doubleClickMaxTime:
			doubleClickSlot = null
			doubleClickTimer = 0
	
	if slotClickedQueue1.size() > 0:
		var highestZ = slotClickedQueue1[0]
		for i in range(1, slotClickedQueue1.size()):
			if not is_instance_valid(highestZ.cardNode) or (is_instance_valid(slotClickedQueue1[i].cardNode) and slotClickedQueue1[i].cardNode.z_index > highestZ.cardNode.z_index):
				highestZ = slotClickedQueue1[i]
		
		if $CardDisplay.slots.has(highestZ):
			if is_instance_valid(doubleClickSlot) and doubleClickSlot == highestZ:
				$DeckDisplayControl/DeckDisplay.addCard(highestZ.cardNode.card.UUID)
				$CardDisplay.slots.erase(highestZ)
				$CardDisplay.nodes.erase(highestZ.cardNode)
				highestZ.cardNode.queue_free()
				highestZ.queue_free()
				$CardDisplay.centerCards()
			else:
				doubleClickSlot = highestZ
		
		slotClickedQueue1.clear()
	
	if slotClickedQueue2.size() > 0:
		var highestZ = slotClickedQueue2[0]
		for i in range(1, slotClickedQueue2.size()):
			if not is_instance_valid(highestZ.cardNode) or (is_instance_valid(slotClickedQueue2[i].cardNode) and slotClickedQueue2[i].cardNode.z_index > highestZ.cardNode.z_index):
				highestZ = slotClickedQueue2[i]
		
		#CHECK FOR STACKS
		
		var isSame = hoveringSlot == highestZ
		closeHoverWindow(true)
		
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
					if is_instance_valid(highestZ.cardNode):
						createHoverNode(pos, highestZ.cardNode.card.getHoverData())
						hoveringSlot = highestZ
					
		slotClickedQueue2.clear()
	elif clickedOff:
		closeHoverWindow()
	
	clickedOff = false

func removeCard(cardUUID : int):
	$CardDisplay.addCard(ListOfCards.getCard(cardUUID))
	
func quitButtonPressed():
	var pop = popupUI.instance()
	if Input.is_key_pressed(KEY_CONTROL):
		pop.init("DEBUG_QUIT", "Go to Deck Editor?", [["Yes", Server, "receivedStartBuilding", []], ["Back", pop, "close", []]])
	else:
		pop.init("Quit Draft", "Are you sure you want to quit? There will be no way to return", [["Yes", self, "closeDraft", []], ["Back", pop, "close", []]])
	$CardHolder.add_child(pop)

func settingsButtonPressed():
	$SettingsHolder/SettingsPage.visible = true

func onMouseDown(slot : CardSlot, buttonIndex):
	if buttonIndex == 1:
		slotClickedQueue1.append(slot)
	elif buttonIndex == 2:
		slotClickedQueue2.append(slot)

func onSlotEnter(slot : CardSlot):
	pass
	
func onSlotExit(slot : CardSlot):
	pass

func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == 2:
		clickedOff = true
