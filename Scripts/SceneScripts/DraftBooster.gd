extends DraftClass

onready var selfID = get_tree().get_network_unique_id()

var numBoosters = 3
var cardsPerBooster = 10
var boosterCount = 0

var boosterQueue := []

var playerIDs := []

var playersDone := []

var popupUI = preload("res://Scenes/UI/PopupUI.tscn")

var closing = false


var hoveringWindow
var hoveringSlot
var hoverScene = preload("res://Scenes/UI/Hover.tscn")

var cardDists = 16
onready var cardWidth = ListOfCards.cardBackground.get_width()
onready var cardHeight = ListOfCards.cardBackground.get_height()

var pickForMe = false

var packNums := {}

var direction : int = 1
var playersReady := {}

func _ready():
	var gameSeed = OS.get_system_time_msecs()
	print("current game seed is ", gameSeed)
	seed(gameSeed)
	
	$DeckDisplayControl/DeckDisplay.parent = self
	$CardDisplay.canReorder = true
	genNewBooster()
	
	if Server.host:
		playerIDs = Server.playerIDs.duplicate()
		playerIDs.append(1)
		playerIDs.shuffle()
		
		Server.sendDraftData([playerIDs])
		
		for player_id in playerIDs:
			packNums[player_id] = 1
			playersReady[player_id] = false
			
		popPackNums()
	
	get_tree().set_auto_accept_quit(false)


func setParams(params : Dictionary):
	if params.has("num_boosters"):
		numBoosters = params["num_boosters"]

func setBoosterReady(player_id):
	print(player_id, " is ready for the next round")
	playersReady[player_id] = true
	
	for player_id in playerIDs:
		if not playersReady[player_id]:
			return
	
	print("--------  All players ready  --------")
	Server.confirmBoosterReady()
	confirmBoosterReady()
	
	for player_id in playerIDs:
		playersReady[player_id] = false

func confirmBoosterReady():
	direction *= -1
	genNewBooster()

func genNewBooster(cards = null):
	if cards == []:
		#Server.setBoosterReady()
		#genNewBooster()
		return
	
	if cards == null:
		setPackNum(selfID, 1)
		if boosterCount == numBoosters:
			if Server.host:
				playerDoneDrafting(1)
			else:
				Server.doneBoosterDraft()
			return
		else:
			boosterCount += 1
			$BoosterNum.text = "Booster: (" + str(boosterCount) + "/" + str(numBoosters) + ")"
			
			cards = []
			while cards.size() != cardsPerBooster:
				var card = ListOfCards.generateCard()
				if card.tier == 1:
					cards.append(card.UUID)
	
	$BoosterDisplay.clear()
	for cID in cards:
		var cn = $BoosterDisplay.addCard(ListOfCards.getCard(cID))
		cn.setCardVisible(false)
		
		
	yield(get_tree().create_timer(0.2), "timeout")
	for node in $BoosterDisplay.nodes.duplicate():
		yield(get_tree().create_timer(0.05), "timeout")
		if is_instance_valid(node):
			node.flip()
			SoundEffectManager.playDrawSound()

var slotClickedQueue1 := []
var slotClickedQueue2 := []
var clickedOff = false

var doubleClickSlot = null
var doubleClickTimer = 0
var doubleClickMaxTime = 0.2

func _physics_process(delta):
	
	
	if pickForMe and $BoosterDisplay.slots.size() > 0:
		slotClickedQueue1.append($BoosterDisplay.slots[randi() % $BoosterDisplay.slots.size()])
	
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
		if highestZ.cardNode.getCardVisible():
		
			if $BoosterDisplay.slots.has(highestZ):
				SoundEffectManager.playDrawSound()
				
				if highestZ == hoveringSlot:
					closeHoverWindow(true)
				
				$CardDisplay.addCardNode(highestZ.cardNode, true)
				
				$BoosterDisplay.slots.erase(highestZ)
				$BoosterDisplay.nodes.erase(highestZ.cardNode)
				
				var cardIDs = []
				for c in $BoosterDisplay.nodes:
					cardIDs.append(c.card.UUID)
				var nextID = getNextPlayerID()
				Server.sendBooster(nextID, cardIDs)
				
				$BoosterDisplay.clear()
				#highestZ.cardNode.queue_free()
				highestZ.queue_free()
				
				setPackNum(selfID, packNums[selfID] - 1)
				if cardIDs.size() == 0:
					Server.setBoosterReady()
					setPackNum(selfID, 0)
				
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
		
		slotClickedQueue1.clear()
	
	if slotClickedQueue2.size() > 0:
		var highestZ = slotClickedQueue2[0]
		for i in range(1, slotClickedQueue2.size()):
			if not is_instance_valid(highestZ.cardNode) or (is_instance_valid(slotClickedQueue2[i].cardNode) and slotClickedQueue2[i].cardNode.z_index > highestZ.cardNode.z_index):
				highestZ = slotClickedQueue2[i]
		
		var isSame = highestZ == hoveringSlot
		closeHoverWindow(true)
			
		if not isSame:
			var pos = highestZ.global_position + Vector2(cardWidth * 3.0/5 * Settings.cardSlotScale, 0)
			createHoverNode(pos, highestZ.cardNode.card.getHoverData())
			hoveringSlot = highestZ
		
		slotClickedQueue2.clear()
	elif clickedOff:
		closeHoverWindow()
	
	if $BoosterDisplay.get_child_count() == 0 and boosterQueue.size() > 0:
		genNewBooster(boosterQueue[0])
		boosterQueue.remove(0)
	
	clickedOff = false
		
func onMouseDown(slot : CardSlot, buttonIndex):
	if not closing:
		if buttonIndex == 1:
			slotClickedQueue1.append(slot)
			
		if buttonIndex == 2:
			slotClickedQueue2.append(slot)

func playerDoneDrafting(player_id):
	if player_id == 1:
		print("Server done drafting")
	else:
		print("Player ", player_id, " done drafting")
	playersDone.append(player_id)
	
	if compDones():
		print("All players done drafting")
		Server.startBuilding()

func removeCard(cardUUID : int):
	$CardDisplay.addCard(ListOfCards.getCard(cardUUID))

func compDones() -> bool:
	if playersDone.size() != playerIDs.size():
		return false
	for n in playersDone:
		if playerIDs.find(n) == -1:
			return false
	for n in playerIDs:
		if playersDone.find(n) == -1:
			return false
	
	return true

func onSlotEnter(slot : CardSlot):
	pass
	
func onSlotExit(slot : CardSlot):
	pass

func closeDraft():
	sendAllBoosters()
	yield(get_tree().create_timer(0.02), "timeout")
	yield(get_tree().create_timer(0.02), "timeout")
	Server.closeServer()
	
	var error = get_tree().change_scene("res://Scenes/StartupScreen.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))

func playerDisconnected(player_id):
	playerIDs.has(player_id)
	playerIDs.erase(player_id)
	packNums.erase(player_id)
	playersReady.erase(player_id)
	clearPackNums()
	popPackNums()

func clearPackNums():
	counter = 0
	for c in $PackNums.get_children():
		if c != $PackNums/NinePatchRect:
			c.queue_free()

func popPackNums():
	for player_id in playerIDs:
		if player_id == selfID:
			popPlayer(Server.username, packNums[selfID])
		else:
			popPlayer(Server.playerNames[player_id], packNums[player_id])
	$PackNums/NinePatchRect.rect_size = Vector2($PackNums.rect_size.x + 32, offY * counter) + Vector2(buffer, buffer)
	$PackNums/NinePatchRect.rect_position = -Vector2(buffer, buffer) / 2

var counter = 0
var offY = 24
var buffer = 16

func popPlayer(username : String, num : int):
	
	var label = Label.new()
	NodeLoc.setLabelParams(label)
	label.text = username
	var length = label.get("custom_fonts/font").get_string_size(username).x
	label.clip_text = true
	label.rect_size.x = $PackNums.rect_size.x
	$PackNums.add_child(label)
	label.rect_position = Vector2(0, offY * counter)
	
	label = Label.new()
	NodeLoc.setLabelParams(label)
	label.text = " :  " + str(num)
	$PackNums.add_child(label)
	label.rect_position = Vector2($PackNums.rect_size.x, offY * counter)
		
	counter += 1

func setPackNum(player_id : int, num : int):
	packNums[player_id] = num
	if player_id == selfID:
		Server.setPackNum(num)
	clearPackNums()
	popPackNums()

func setDraftData(data : Array):
	print("got draft data : ", data)
	playerIDs = data[0]
	
	for player_id in playerIDs:
		packNums[player_id] = 1
	popPackNums()

func onQuitButtonPressed():
	if not closing:
		var pop = popupUI.instance()
		if Input.is_key_pressed(KEY_CONTROL):
			pop.init("DEBUG_QUIT", "Go to Deck Editor?", [["Yes", Server, "receivedStartBuilding", []], ["Back", pop, "close", []]])
		else:
			pop.init("Quit Draft", "Are you sure you want to quit? There will be no way to return", [["Yes", self, "closeDraft", []], ["Back", pop, "close", []]])
		$CenterControl.add_child(pop)

func onSettingsPressed():
	$SettingsHolder/SettingsPage.visible = true

func _exit_tree():
	if Server.online and getNextPlayerID() != selfID:
		sendAllBoosters()
	get_tree().set_auto_accept_quit(true)

func getNextPlayerID() -> int:
	var myIndex = playerIDs.find(selfID)
	var nextID = playerIDs[(myIndex + direction) % playerIDs.size()]
	return nextID

func addToBoosterQueue(boosterData):
	boosterQueue.append(boosterData)
	if boosterData.size() > 0:
		setPackNum(selfID, packNums[selfID] + 1)

func sendAllBoosters():
	if playerIDs.size() > 0 and not closing:
		var boostersData = []
		var b = []
		for node in $BoosterDisplay.nodes:
			b.append(node.card.UUID)
		if b.size() > 0:
			boostersData.append(b)
		
		boostersData += boosterQueue
		
		Server.sendAllBoosters(getNextPlayerID(), boostersData)

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		sendAllBoosters()
		closing = true
		yield(get_tree().create_timer(0.1), "timeout")
		Server.closeServer()
		get_tree().quit()


func createHoverNode(position : Vector2, text : String):
	var hoverInst = hoverScene.instance()
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
	if event is InputEventKey and event.is_pressed() and not event.is_echo() and event.scancode == KEY_F3:
		pickForMe = not pickForMe
