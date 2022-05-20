extends Node

var availableCardCount : Dictionary = {}

var popupUI = preload("res://Scenes/UI/PopupUI.tscn")

var nums := []

var slotPageWidth = 5
var slotPageHeight = 3
var slotPageNum = slotPageWidth * slotPageHeight

var cardSlot = preload("res://Scenes/CardSlot.tscn")
var cardNode = preload("res://Scenes/CardNode.tscn")
onready var cardWidth = ListOfCards.cardBackground.get_width()
onready var cardHeight = ListOfCards.cardBackground.get_height()
var hoverScene = preload("res://Scenes/UI/Hover.tscn")
var cardDists = 16

var currentPage := -1 setget setCurrentPage, getCurrentPage
var pages := []

var hasSaved = true

enum SORT_ORDER {TYPE, POWER, HEALTH, RARITY, NAME}
var sortOrder : int = SORT_ORDER.TYPE

var loadedDeckName = ""

var popups := []

onready var fileDisplay = $CenterControl/OptionDisplay

enum FILE_WHAT {NONE, LOAD, DELETE}
var fileWhat = FILE_WHAT.NONE

var idToLabel : Dictionary = {}

func _ready():
	BackgroundFusion.pause()
	MusicManager.playDeckEditorMusic()
	
	$CenterControl/DeckDisplay.parent = self
	setCards()
	
	fileDisplay.connect("onBackPressed", self, "onBackPressed")
	fileDisplay.connect("onOptionPressed", self, "onFilePressed")
	
	for k in SORT_ORDER.keys():
		$CenterControl/SortNode/HBoxContainer/SortButton.add_item(k.capitalize())
	
	$CenterControl/SortNode/HBoxContainer/SortButton.select(0)
	setSortOrder(0)
	
	
	if Settings.gameMode != Settings.GAME_MODE.NONE and Server.online:
		popPlayersReady()

func checkReady():
	clearPlayersReady()
	popPlayersReady()

func clearPlayersReady():
	for c in $CenterControl/OpponentDisplay.get_children():
		c.queue_free()

func popPlayersReady():
	for player_id in Server.playerIDs:
		var label = Label.new()
		label.clip_text = true
		label.rect_size.x = $CenterControl/OpponentDisplay.rect_size.x
		label.text = Server.playerNames[player_id]
		NodeLoc.setLabelParams(label, true)
		idToLabel[player_id] = label
		$CenterControl/OpponentDisplay.add_child(label)
		
		var sprite = Sprite.new()
		sprite.texture = checkTex if Server.playersReady[player_id] else uncheckTex
		label.add_child(sprite)
		sprite.position.x = label.rect_size.x - sprite.texture.get_width()
		sprite.position.y = label.rect_size.y / 2

func setCards():
	if Settings.gameMode == Settings.GAME_MODE.NONE:
		for k in ListOfCards.cardList.keys():
			var c = ListOfCards.cardList[k]
			if c.tier == 1:
				if c.rarity == Card.RARITY.BASIC:
					availableCardCount[k] = -1
				elif c.rarity == Card.RARITY.COMMON:
					availableCardCount[k] = 4
				elif c.rarity == Card.RARITY.LEGENDARY:
					availableCardCount[k] = 1
				elif c.rarity == Card.RARITY.VANGUARD:
					availableCardCount[k] = 1
		
		for k in ListOfCards.cardList.keys():
			if ListOfCards.cardList[k].tier == 1:
				if ListOfCards.cardList[k].rarity == Card.RARITY.BASIC:
					availableCardCount[k] = -1
				elif ListOfCards.cardList[k].rarity == Card.RARITY.COMMON:
					availableCardCount[k] = 4
				elif ListOfCards.cardList[k].rarity == Card.RARITY.LEGENDARY:
					availableCardCount[k] = 1
				elif ListOfCards.cardList[k].rarity == Card.RARITY.VANGUARD:
					availableCardCount[k] = 1
					
	else:
		if Server.playerIDs.size() > 0:
			$CenterControl/Menu/ReadyButton.show()
		$CenterControl/Menu/DeleteButton.hide()
		$CenterControl/Menu/NewButton.hide()
		$CenterControl/Menu/LoadButton.hide()
		hasSaved = false

func clearPages():
	slotViewing = null
	slotReturning = null

	while pages.size() > 0:
		for s in pages[0].get_children():
			s.queue_free()
		pages[0].queue_free()
		pages.erase(pages[0])

func setSortOrder(order : int):
	sortOrder = order
	sort()

func sort():
	clearPages()
	var listOfCards := []
	for k in availableCardCount.keys():
		var c = ListOfCards.getCard(k)
		listOfCards.append(c)
	
	#SORT BY: TYPE   = TYPE,  RARITY, NAME
	#SORT BY: POWER  = POWER, RARITY, TYPE, NAME
	#SORT BY: TOUGH  = TOUGH, RARITY, TYPE, NAME
	#SORT BY: RARITY = RARITY, TYPE,  NAME
	
	var cardsToAdd = sortArray(listOfCards, sortOrder)
	
	if sortOrder == SORT_ORDER.TYPE:
		for i in range(cardsToAdd.size()):
			var newPage = []
			var r = sortArray(cardsToAdd[i], SORT_ORDER.RARITY)
			for ra in r:
				for t in sortArray(ra, SORT_ORDER.NAME):
					newPage.append(t[0])
			cardsToAdd[i] = newPage
	elif sortOrder == SORT_ORDER.POWER or sortOrder == SORT_ORDER.HEALTH:
		for i in range(cardsToAdd.size()):
			var newPage = []
			for r in sortArray(cardsToAdd[i], SORT_ORDER.RARITY):
				for t in sortArray(r, SORT_ORDER.TYPE):
					for n in sortArray(t, SORT_ORDER.NAME):
						newPage.append(n[0])
			cardsToAdd[i] = newPage
	elif sortOrder == SORT_ORDER.RARITY:
		for i in range(cardsToAdd.size()):
			var newPage = []
			for t in sortArray(cardsToAdd[i], SORT_ORDER.TYPE):
				for n in sortArray(t, SORT_ORDER.NAME):
					newPage.append(n[0])
			cardsToAdd[i] = newPage
	elif sortOrder == SORT_ORDER.NAME:
		var newPage = []
		for n in cardsToAdd:
			newPage.append(n[0])
		cardsToAdd = [newPage]
		
	
	var n = 0
	while n < cardsToAdd.size():
		if cardsToAdd[n].size() > slotPageNum:
			var p1 = []
			var p2 = []
			for i in range(cardsToAdd[n].size()):
				if i < slotPageNum:
					p1.append(cardsToAdd[n][i])
				else:
					p2.append(cardsToAdd[n][i])
			cardsToAdd.remove(n)
			cardsToAdd.insert(n, p2)
			cardsToAdd.insert(n, p1)
		n += 1
	
	for k in cardsToAdd:
		var mod
		if k.size() == 0:
			mod = 0
		elif k.size() % slotPageNum == 0:
			mod = slotPageNum
		else:
			mod = k.size() % slotPageNum
		var remainder = slotPageNum - mod
		
		for i in range(remainder):
			k.append(null)
	
	for i in range(cardsToAdd.size()):
		var page = Node2D.new()
		page.name = "page_" + str(i)
		$CenterControl/PageHolder.add_child(page)
		page.visible = false
		pages.append(page)
		for j in range(slotPageNum):
			var x = j % slotPageWidth
			var y = j / slotPageWidth
			var offX = (x - (slotPageWidth - 1) / 2.0) * (cardWidth + cardDists)
			var offY = (y - (slotPageHeight - 1) / 2.0) * (cardHeight + cardDists*2)
			
			var slot = cardSlot.instance()
			slot.currentZone = CardSlot.ZONES.NONE
			page.add_child(slot)
			slot.position = Vector2(offX, offY)
			
			var card = cardsToAdd[i][j]
			if card != null:
				var cardPlacing = cardNode.instance()
				cardPlacing.z_index = 0
				cardPlacing.card = card
				cardPlacing.card.cardNode = cardPlacing
				page.add_child(cardPlacing)
				cardPlacing.global_position = slot.global_position
				slot.cardNode = cardPlacing
				cardPlacing.slot = slot
				
				updateSlotCount(slot)
	
	var offL = (-2 - (slotPageWidth - 1) / 2.0) * (cardWidth + cardDists)
	$CenterControl/LArrow.position = Vector2(offL, 30)
	var offR = (slotPageWidth + 1 - (slotPageWidth - 1) / 2.0) * (cardWidth + cardDists) + 8
	$CenterControl/RArrow.position = Vector2(offR, 30)
	
	setCurrentPage(0)

static func sortArray(listOfCards : Array, sortOrder : int) -> Array:
	var cardPages := {}
	
	for c in listOfCards:
		if c.tier == 1:
			var key = 0
			if sortOrder == SORT_ORDER.POWER:
				key = -c.power
			elif sortOrder == SORT_ORDER.HEALTH:
				key = -c.toughness
			elif sortOrder == SORT_ORDER.TYPE:
				for t in c.creatureType:
					key |= 1 << t
				key += (c.creatureType.size() - 1) * 10000
			elif sortOrder == SORT_ORDER.RARITY:
				key = -c.rarity
			elif sortOrder == SORT_ORDER.NAME:
				key = c.name
			
			if not cardPages.has(key):
				cardPages[key] = [c]
			else:
				cardPages[key].append(c)
	
	var cardsToAdd := []
	while cardPages.size() > 0:
		var lowest = cardPages.keys()[0]
		for i in range(1, cardPages.keys().size()):
			if cardPages.keys()[i] < lowest:
				lowest = cardPages.keys()[i]
		cardsToAdd.append(cardPages[lowest])
		cardPages.erase(lowest)
	
	return cardsToAdd

func leftArrowPressed():
	setCurrentPage(getCurrentPage() - 1)

func rightArrowPressed():
	setCurrentPage(getCurrentPage() + 1)

func _physics_process(delta):
	slotClicked = false
	
	if slotViewing != null:
		if viewTimer < viewMaxTime:
			viewTimer += delta
			slotViewing.cardNode.global_position = lerp(slotViewing.global_position, $CenterControl.rect_global_position, viewTimer / viewMaxTime)
			#slotViewing.cardNode.scale.x = cos(abs(2 * PI * viewTimer / viewMaxTime))
			slotViewing.cardNode.scale = lerp(Vector2(1, 1), Vector2(viewScale, viewScale), viewTimer / viewMaxTime)
		else:
			if not is_instance_valid(infoWindow):
				createHoverNode(Vector2(-cardWidth * viewScale * 0.5 * Settings.cardSlotScale, 0), slotViewing.cardNode.card.getHoverData())
	if slotReturning != null:
		if returnTimer < returnMaxTime:
			returnTimer += delta
			if returnTimer > returnMaxTime:
				slotReturning.cardNode.global_position = slotReturning.global_position
				slotReturning.cardNode.scale = Vector2(1, 1)
				slotReturning.cardNode.z_index -= 1
				slotReturning = null
			else:
				slotReturning.cardNode.global_position = lerp($CenterControl.rect_global_position, slotReturning.global_position, returnTimer / returnMaxTime)
				slotReturning.cardNode.scale = lerp(Vector2(viewScale, viewScale), Vector2(1, 1), returnTimer / returnMaxTime)

func onSlotEnter(slot : CardSlot):
	pass
	
func onSlotExit(slot : CardSlot):
	pass
	
var slotViewing = null
var viewTimer = 0
var viewMaxTime = 0.15
var viewScale = 3
var slotReturning = null
var returnTimer = 0
var returnMaxTime = 0.3
var infoWindow = null
	
func createHoverNode(position : Vector2, text : String):
	var hoverInst = hoverScene.instance()
	hoverInst.closeChildrenFirst = true
	hoverInst.z_index = 3
	hoverInst.flipped = true
	$CenterControl.add_child(hoverInst)
	hoverInst.position = position
	hoverInst.setText(text)
	infoWindow = hoverInst

func removeCard(id : int):
	var slot = null
	for p in pages:
		for s in p.get_children():
			if s is CardSlot and is_instance_valid(s.cardNode):
				if s.cardNode.card.UUID == id:
					slot = s
	updateSlotCount(slot)
	
	if ready:
		var error = Deck.verifyDeck($CenterControl/DeckDisplay.getDeckDataAsJSON())
		if error != Deck.DECK_VALIDITY_TYPE.VALID:
			onReadyPressed()
	

var slotClicked = false
func onMouseDown(slot : CardSlot, button_index : int):
	if not $CenterControl/SaveDisplay.visible and not fileDisplay.visible and is_instance_valid(slot.cardNode):
		if button_index == 1:
			var countCheck = true
			for i in $CenterControl/DeckDisplay.data.size():
				if $CenterControl/DeckDisplay.data[i].card.UUID == slot.cardNode.card.UUID:
					countCheck = availableCardCount[slot.cardNode.card.UUID] == -1 or $CenterControl/DeckDisplay.data[i].count < availableCardCount[slot.cardNode.card.UUID]
					break
			
			if slot.cardNode != null and slotViewing == null and countCheck:
				$CenterControl/DeckDisplay.addCard(slot.cardNode.card.UUID)
				updateSlotCount(slot)
				
		elif button_index == 2:
			if slotViewing == null and slotReturning == null and slot.cardNode != null and slot.get_parent().visible:
				slotViewing = slot
				slotViewing.cardNode.z_index += 2
				viewTimer = 0
				slotClicked = true
				$CenterControl/DeckDisplay.closeDeckDisplayHover(true)
				
func onMouseUp(slot : CardSlot, button_index : int):
	pass

func updateSlotCount(slot : CardSlot):
	var index = -1
	for i in range($CenterControl/DeckDisplay.data.size()):
		if $CenterControl/DeckDisplay.data[i].card.UUID == slot.cardNode.card.UUID:
			index = i
			break
	if availableCardCount[slot.cardNode.card.UUID] == -1:
		slot.get_node("Label").text = ""
	elif index >= 0:
		slot.get_node("Label").text = str($CenterControl/DeckDisplay.data[index].count) + "/" + str(availableCardCount[slot.cardNode.card.UUID])
	else:
		slot.get_node("Label").text = "0/" + str(availableCardCount[slot.cardNode.card.UUID])

func onLoadPressed():
	if not hasSaved:
		var pop = popupUI.instance()
		pop.init("Unsaved Changes", "You have unsaved changes. Are you sure you want to load a new deck?", [["Yes", self, "onConfirmLoad", [pop]], ["Back", self, "closePopupUI", [pop]]])
		$CenterControl.add_child(pop)
		pop.options[1].grab_focus()
		popups.append(pop)
	else:
		onConfirmLoad()
		
func onSavePressed():
	$CenterControl/SaveDisplay.visible = true
	$CenterControl/SaveDisplay/Background/LineEdit.grab_focus()
	$CenterControl/SaveDisplay/Background/LineEdit.text = loadedDeckName.get_basename()
	$CenterControl/SaveDisplay/Background/LineEdit.caret_position = loadedDeckName.get_basename().length()
	
func onNewPressed():
	if not hasSaved:
		var pop = popupUI.instance()
		pop.init("Unsaved Changes", "You have unsaved changes. Are you sure you want to start a new deck?", [["Yes", self, "onConfirmNew", [pop]], ["Back", self, "closePopupUI", [pop]]])
		$CenterControl.add_child(pop)
		pop.options[1].grab_focus()
		popups.append(pop)
	else:
		onConfirmNew()
		
func onDeleteButtonPressed():
	var decks : Dictionary = SilentWolf.Players.player_data["decks"]
	var options : Array = decks.keys()
	options.sort()
	var keys : Array = []
	for d in options:
		keys.append(decks[d])
	fileDisplay.setOptions("Select Deck", options, keys)
	
	$CenterControl/DeckDisplay.canScroll = false
	fileWhat = FILE_WHAT.DELETE
	
func onSaveEnter(s : String):
	onFileSaveButtonPressed()
	
func onExitPressed():
	if not hasSaved:
		var pop = popupUI.instance()
		pop.init("Unsaved Changes", "You have unsaved changes. Are you sure you want to exit?", [["Yes", self, "onConfirmExit", [pop]], ["Back", self, "closePopupUI", [pop]]])
		$CenterControl.add_child(pop)
		pop.options[1].grab_focus()
		popups.append(pop)
	else:
		onConfirmExit()

func closePopupUI(popup=null):
	if popup != null:
		popups.erase(popup)
		popup.close()

func onConfirmNew(popup=null):
	if popup != null:
		popups.erase(popup)
		popup.close()
	$CenterControl/DeckDisplay.clearData()
	hasSaved = true
	loadedDeckName = ""
	
func onConfirmExit(popup=null):
	if popup != null:
		popups.erase(popup)
		popup.close()
	
	var root = get_node("/root")
	var startup = load("res://Scenes/StartupScreen.tscn").instance()
	
	startup.onPlayPressed()
	root.add_child(startup)
	get_tree().current_scene = startup
	
	root.remove_child(self)
	queue_free()

func onConfirmLoad(popup=null):
	if popup != null:
		popups.erase(popup)
		popup.close()
	
	fileWhat = FILE_WHAT.LOAD
	var decks : Dictionary = SilentWolf.Players.player_data["decks"]
	var options : Array = decks.keys()
	options.sort()
	var keys : Array = []
	for d in options:
		keys.append(decks[d])
	fileDisplay.setOptions("Select Deck", options, keys)
	$CenterControl/DeckDisplay.canScroll = false

func onBackPressed(popup=null):
	if popup != null:
		popups.erase(popup)
		popup.close()
	
	fileDisplay.hide()
	$CenterControl/DeckDisplay.canScroll = true
	fileWhat = FILE_WHAT.NONE
	fileToDelete = ""

var fileToDelete = ""

func onFilePressed(button : Button, key):
	if fileWhat == FILE_WHAT.LOAD:
		var error = Deck.verifyDeck(key)
		print("Deck validity: " + str(error))
		if error == Deck.DECK_VALIDITY_TYPE.VALID:
			$CenterControl/DeckDisplay.clearData()
			for dat in key.keys():
				for k in key[dat].keys():
					var id = int(k)
					for i in range(int(key[dat][k])):
						$CenterControl/DeckDisplay.addCard(id)
						
						for p in pages:
							for c in p.get_children():
								if c is CardSlot and is_instance_valid(c.cardNode):
									updateSlotCount(c)
			hasSaved = true
			
			loadedDeckName = button.text
		else:
			print("Deck file is not valid")
			
			var pop = popupUI.instance()
			pop.init("Error Loading Deck", "Error loading " + button.text + "\nop_code=" + str(error) + " : " + Deck.DECK_VALIDITY_TYPE.keys()[error], [["Close", self, "closePopupUI", [pop]]])
			$CenterControl.add_child(pop)
			pop.options[0].grab_focus()
			popups.append(pop)
			
		onBackPressed()
	elif fileWhat == FILE_WHAT.DELETE:
		fileToDelete = button.text
		fileDisplay.visible = false
		var pop = popupUI.instance()
		pop.init("Delete Deck", "Are you sure you want to delete " + button.text, [["Yes", self, "onDeleteConfirmed", [pop]], ["Back", self, "onBackPressed", [pop]]])
		$CenterControl.add_child(pop)
		pop.options[1].grab_focus()
		popups.append(pop)
	else:
		onBackPressed()
	
func onDeleteConfirmed(popup=null):
	var bak = SilentWolf.Players.player_data["decks"][fileToDelete]
	SilentWolf.Players.player_data["decks"].erase(fileToDelete)
	$CenterControl/LoadingOffset/LoadingWindow.get_node("Label").text = "Deleting Deck"
	onBackPressed(popup)
	$CenterControl/LoadingOffset/LoadingWindow.show()
	var out = yield(SilentWolf.Players.post_player_data(SilentWolf.Auth.logged_in_player, SilentWolf.Players.player_data), "sw_player_data_posted")
	$CenterControl/LoadingOffset/LoadingWindow.hide()
	if out:
		var pop = popupUI.instance()
		pop.init("Deck Deleted", "", [["Close", self, "closePopupUI", [pop]]])
		$CenterControl.add_child(pop)
		pop.options[0].grab_focus()
		popups.append(pop)
	else:
		SilentWolf.Players.player_data["decks"][fileToDelete] = bak
		var pop = popupUI.instance()
		pop.init("Error Deleting Deck", "Could not connect to server", [["Close", self, "closePopupUI", [pop]]])
		$CenterControl.add_child(pop)
		pop.options[0].grab_focus()
		popups.append(pop)
		
func onFileSaveBackPressed():
	$CenterControl/SaveDisplay/Background/LineEdit.text = ""
	$CenterControl/SaveDisplay.visible = false
	
func onFileSaveButtonPressed():
	
	var fileName : String = $CenterControl/SaveDisplay/Background/LineEdit.text
	$CenterControl/SaveDisplay/Background/LineEdit.release_focus()
	$CenterControl/SaveDisplay/Background/SaveButton.release_focus()
	
	if fileName.empty():
		SilentWolf.Players.player_data["decks"].erase(fileName)
		var pop = popupUI.instance()
		pop.init("Error Saving Deck", "Deck name cannot be empty", [["Close", self, "closePopupUI", [pop]]])
		$CenterControl.add_child(pop)
		pop.options[0].grab_focus()
		popups.append(pop)
	else:
		var error = Deck.verifyDeck($CenterControl/DeckDisplay.getDeckDataAsJSON())
		if error == Deck.DECK_VALIDITY_TYPE.VALID:
			SilentWolf.Players.player_data["decks"][fileName] = $CenterControl/DeckDisplay.getDeckData()
			$CenterControl/LoadingOffset/LoadingWindow.get_node("Label").text = "Saving Deck"
			$CenterControl/LoadingOffset/LoadingWindow.show()
			var out = yield(SilentWolf.Players.post_player_data(SilentWolf.Auth.logged_in_player, SilentWolf.Players.player_data), "sw_player_data_posted")
			$CenterControl/LoadingOffset/LoadingWindow.hide()
			if out:
				print("Deck successfully saved")
				var pop = popupUI.instance()
				pop.init("Deck Saved", "", [["Close", self, "closePopupUI", [pop]]])
				$CenterControl.add_child(pop)
				hasSaved = true
				loadedDeckName = fileName
				pop.options[0].grab_focus()
				popups.append(pop)
			else:
				SilentWolf.Players.player_data["decks"].erase(fileName)
				var pop = popupUI.instance()
				pop.init("Error Saving Deck", "Could not connect to server", [["Close", self, "closePopupUI", [pop]]])
				$CenterControl.add_child(pop)
				pop.options[0].grab_focus()
				popups.append(pop)
			
			
			
			
		else:
			var pop = popupUI.instance()
			pop.init("Error Verifying Deck", "Error verifying\nop_code=" + str(error) + " : " + Deck.DECK_VALIDITY_TYPE.keys()[error], [["Close", self, "closePopupUI", [pop]]])
			$CenterControl.add_child(pop)
			pop.options[0].grab_focus()
			popups.append(pop)
	
	onFileSaveBackPressed()

var ready = false
var checkTex = preload("res://Art/UI/check.png")
var uncheckTex = preload("res://Art/UI/un_check.png")
func onReadyPressed():
	if not ready:
		var error = Deck.verifyDeck($CenterControl/DeckDisplay.getDeckDataAsJSON())
		if error == Deck.DECK_VALIDITY_TYPE.VALID:
			if startTournament():
				ready = not ready
				$CenterControl/Menu/ReadyButton/Sprite.texture = checkTex if ready else uncheckTex
				Server.setReady(ready)
		else:
			var pop = popupUI.instance()
			pop.init("Error Verifying Deck", "Error verifying\nop_code=" + str(error) + " : " + Deck.DECK_VALIDITY_TYPE.keys()[error], [["Close", self, "closePopupUI", [pop]]])
			$CenterControl.add_child(pop)
			pop.options[0].grab_focus()
			popups.append(pop)
	else:
		ready = not ready
		$CenterControl/Menu/ReadyButton/Sprite.texture = checkTex if ready else uncheckTex
		Server.setReady(ready)
		
func startTournament() -> bool:
	Settings.deckData = $CenterControl/DeckDisplay.getDeckData()
	return true

func deckModified():
	hasSaved = false
	
func setCurrentPage(newPage : int):
	if pages.size() == 0:
		return
	newPage = max(min(newPage, pages.size() - 1), 0)
	
	if slotViewing != null and currentPage != newPage:
		if is_instance_valid(infoWindow):
			infoWindow.close(true)
		slotViewing.cardNode.global_position = slotViewing.global_position
		slotViewing.cardNode.scale = Vector2(1, 1)
		slotViewing.cardNode.z_index -= 1
		slotViewing = null
	
	if currentPage >= 0 and currentPage < pages.size():
		pages[currentPage].visible = false
	currentPage = newPage
	pages[newPage].visible = true
	
	$CenterControl/LArrow.visible = currentPage != 0
	$CenterControl/RArrow.visible = currentPage != pages.size() - 1

func getCurrentPage() -> int:
	return currentPage

func onRandomizePressed():
	if not hasSaved:
		var pop = popupUI.instance()
		pop.init("Unsaved Changes", "You have unsaved changes. Are you sure you want to create a random deck?", [["Yes", self, "randomizeDeck", [pop]], ["Back", self, "closePopupUI", [pop]]])
		$CenterControl.add_child(pop)
		pop.options[1].grab_focus()
		popups.append(pop)
	else:
		randomizeDeck()

func randomizeDeck(popup=null):
	if popup != null:
		popups.erase(popup)
		popup.close()
	
	$CenterControl/DeckDisplay.clearData()
	hasSaved = true
	loadedDeckName = ""
	
	while $CenterControl/DeckDisplay.getTotal() < 20:
		var id = availableCardCount.keys()[randi() % availableCardCount.keys().size()]
		var card = ListOfCards.getCard(id)
		
		var countCheck = true
		for i in $CenterControl/DeckDisplay.data.size():
			if $CenterControl/DeckDisplay.data[i].card.UUID == id:
				if card.rarity == Card.RARITY.COMMON:
					countCheck = availableCardCount[id] == -1 or $CenterControl/DeckDisplay.data[i].count < availableCardCount[id]
				else:
					countCheck = false
				break
		
		if countCheck:
			$CenterControl/DeckDisplay.addCard(id)

func _input(event):
	if event is InputEventKey and event.is_pressed() and not event.is_echo() and not ($CenterControl/SaveDisplay.visible or fileDisplay.visible) and popups.size() == 0:
		if Input.is_key_pressed(KEY_CONTROL):
			if event.scancode == KEY_S:
				onSavePressed()
			elif event.scancode == KEY_N:
				onNewPressed()
			elif event.scancode == KEY_O:
				onLoadPressed()
			elif event.scancode == KEY_DELETE:
				onDeleteButtonPressed()
		else:
			if event.scancode == KEY_A or event.scancode == KEY_LEFT:
				leftArrowPressed()
			elif event.scancode == KEY_D or event.scancode == KEY_RIGHT:
				rightArrowPressed()
	
	if event is InputEventKey and event.is_pressed() and not event.is_echo() and event.scancode == KEY_ESCAPE:
		if $CenterControl/SaveDisplay.visible:
			onFileSaveBackPressed()
		elif fileDisplay.visible:
			onBackPressed()
		elif popups.size() > 0:
			popups[popups.size()-1].close()
			popups.remove(popups.size()-1)
		else:
			onExitPressed()
	
	if not slotClicked:
		if event is InputEventMouseButton:
			if event.pressed and (event.button_index == 2):
				if is_instance_valid(slotViewing) and slotReturning == null:
					yield(get_tree().create_timer(0.02), "timeout")
					if is_instance_valid(slotViewing) and slotReturning == null:
						if is_instance_valid(infoWindow) and infoWindow.spawnedWindows.size() > 0:
							infoWindow.close()
						else:
							if is_instance_valid(infoWindow):
								infoWindow.close(true)
							slotReturning = slotViewing
							slotViewing.cardNode.z_index -= 1
							slotViewing = null
							returnTimer = 0

