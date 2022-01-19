extends Node2D
	
var slotPageWidth = 6
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

enum SORT_ORDER {TYPE, POWER, TOUGHNESS}
var sortOrder : int = SORT_ORDER.TYPE

func _ready():
	sort()

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
	for i in range(ListOfCards.cardList.size()):
		var c = ListOfCards.getCard(i)
		if c.tier <= 1:
			listOfCards.append(c)
	
	var cardsToAdd = []
	if sortOrder == SORT_ORDER.TYPE or sortOrder == SORT_ORDER.POWER or sortOrder == SORT_ORDER.TOUGHNESS:
		for i in Card.CREATURE_TYPE.values():
			for j in Card.CREATURE_TYPE.values():
				var typesToComp = []
				if i != 0:
					typesToComp.append(i)
				if j != 0:
					typesToComp.append(j)
					
				for c in listOfCards:
					var hasAll = true
					for t in c.creatureType:
						if not typesToComp.has(t):
							hasAll = false
					if hasAll:
						cardsToAdd.append(c)
						listOfCards.erase(c)
	if sortOrder == SORT_ORDER.POWER or sortOrder == SORT_ORDER.TOUGHNESS:
		for c in cardsToAdd:
			listOfCards.append(c)
		cardsToAdd = []
		while listOfCards.size() > 0:
			var highest = null
			for c in listOfCards:
				if highest == null:
					highest = c
				else:
					var compA
					var compB
					if sortOrder == SORT_ORDER.POWER:
						compA = highest.power
						compB = c.power
					elif sortOrder == SORT_ORDER.TOUGHNESS:
						compA = highest.toughness
						compB = c.toughness
					if compB > compA:
						highest = c
			cardsToAdd.append(highest)
			listOfCards.erase(highest)
				
	var mod
	if cardsToAdd.size() == 0:
		mod = 0
	elif cardsToAdd.size() % slotPageNum == 0:
		mod = slotPageNum
	else:
		mod = cardsToAdd.size() % slotPageNum
		
	var remainder = slotPageNum - mod
	for i in range(remainder):
		cardsToAdd.append(null)
			
	for i in range(cardsToAdd.size() / slotPageNum):
		var page = Node2D.new()
		page.name = "page_" + str(i)
		$PageHolder.add_child(page)
		page.visible = false
		pages.append(page)
		for j in range(slotPageNum):
			var x = j % slotPageWidth
			var y = j / slotPageWidth
			var offX = (x - (slotPageWidth - 1) / 2.0) * (cardWidth + cardDists)
			var offY = (y - (slotPageHeight - 1) / 2.0) * (cardHeight + cardDists)
			
			var slot = cardSlot.instance()
			slot.currentZone = CardSlot.ZONES.NONE
			slot.board = self
			page.add_child(slot)
			slot.position = Vector2(offX, offY)
			
			var card = cardsToAdd[i * slotPageNum + j]
			if card != null:
				var cardPlacing = cardNode.instance()
				cardPlacing.card = card
				page.add_child(cardPlacing)
				cardPlacing.global_position = slot.global_position
				slot.cardNode = cardPlacing
				cardPlacing.slot = slot
	setCurrentPage(0)
	hasSaved = true

func _physics_process(delta):
	if slotViewing != null:
		if viewTimer < viewMaxTime:
			viewTimer += delta
			slotViewing.cardNode.global_position = lerp(slotViewing.global_position, $PageHolder.position, viewTimer / viewMaxTime)
			#slotViewing.cardNode.scale.x = cos(abs(2 * PI * viewTimer / viewMaxTime))
			slotViewing.cardNode.scale = lerp(Vector2(1, 1), Vector2(viewScale, viewScale), viewTimer / viewMaxTime)
		else:
			if not is_instance_valid(infoWindow):
				print(get_viewport_rect().size / 2)
				createHoverNode(Vector2(-cardWidth * viewScale * 3.0/5, 0), slotViewing.cardNode.card.getHoverData())
	if slotReturning != null:
		if returnTimer < returnMaxTime:
			returnTimer += delta
			if returnTimer > returnMaxTime:
				slotReturning.cardNode.global_position = slotReturning.global_position
				slotReturning.cardNode.scale = Vector2(1, 1)
				slotReturning.cardNode.z_index -= 1
				slotReturning = null
			else:
				slotReturning.cardNode.global_position = lerp($PageHolder.position, slotReturning.global_position, returnTimer / returnMaxTime)
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
	hoverInst.z_index = 3
	add_child(hoverInst)
	hoverInst.global_position = position
	hoverInst.flipped = true
	hoverInst.setText(text)
	infoWindow = hoverInst
	
func slotClicked(slot : CardSlot, button_index : int, fromServer = false):
	if button_index == 1:
		if slot.cardNode != null and slotViewing == null:
			$DeckDisplay.addCard(slot.cardNode.card.UUID)
			return
	elif button_index == 2:
		if slotViewing == null and slot.cardNode != null:
			slotViewing = slot
			slotViewing.cardNode.z_index += 2
			viewTimer = 0
	
func onLoadPressed():
	confirmType = CONFIRM_TYPES.LOAD
	if not hasSaved:
		$ConfirmNode.visible = true
	else:
		onConfirmYesPressed()
		
func onSavePressed():
	$SaveDisplay.visible = true
	
enum CONFIRM_TYPES {NONE, NEW, EXIT, LOAD, DELETE}
var confirmType = CONFIRM_TYPES.NONE
	
func onNewPressed():
	confirmType = CONFIRM_TYPES.NEW
	if not hasSaved:
		$ConfirmNode.visible = true
	else:
		onConfirmYesPressed()
	
func onExitPressed():
	confirmType = CONFIRM_TYPES.EXIT
	if not hasSaved:
		$ConfirmNode.visible = true
	else:
		onConfirmYesPressed()
	
func onConfirmYesPressed():
	
	if confirmType == CONFIRM_TYPES.NEW:
		$DeckDisplay.clearData()
		hasSaved = true
		
		
	elif confirmType == CONFIRM_TYPES.EXIT:
		var error = get_tree().change_scene("res://Scenes/StartupScreen.tscn")
		if error != 0:
			print("Error loading test1.tscn. Error Code = " + str(error))
			
			
	elif confirmType == CONFIRM_TYPES.LOAD:
		$FileDisplay.visible = true
		$FileDisplay/ButtonHolder/Label.text = "Load File"
		
		var files = []
		var dir = Directory.new()
		dir.open(Settings.path)
		dir.list_dir_begin()
		while true:
			var file = dir.get_next()
			if file == "":
				break
			elif not file.begins_with(".") and file.ends_with("json"):
				files.append(file)
		dir.list_dir_end()
		
		for c in $FileDisplay/ButtonHolder.get_children():
			if c is Button and c.name != "BackButton":
				c.queue_free()
		for i in range(files.size()):
			var b = Button.new()
			$FileDisplay/ButtonHolder.add_child(b)
			b.text = str(files[i])
			b.connect("pressed", self, "onFileLoadButtonPressed", [files[i]])
			$FileDisplay/ButtonHolder.move_child(b, i+1)
		$FileDisplay/ButtonHolder.set_anchors_and_margins_preset(Control.PRESET_CENTER)
		$FileDisplay/Background.rect_size = $FileDisplay/ButtonHolder.rect_size + Vector2(60, 20)
		$FileDisplay/Background.rect_position = $FileDisplay/ButtonHolder.rect_position - Vector2(30, 10)
			
			
	$ConfirmNode.visible = false
	confirmType = CONFIRM_TYPES.NONE
	
func onConfirmNoPressed():
	$ConfirmNode.visible = false
	confirmType = CONFIRM_TYPES.NONE
		
func onFileLoadBackPressed():
	$FileDisplay.visible = false
	
func onFileLoadButtonPressed(fileName : String):
	print("File ", fileName, " selected")
	
	var dataRead = FileIO.readJSON(Settings.path + fileName)
	var error = Deck.verifyDeck(dataRead)
	print("Deck validity: " + str(error))
	if error == Deck.DECK_VALIDITY_TYPE.VALID:
		$DeckDisplay.clearData()
		for k in dataRead.keys():
			var id = int(k)
			for i in range(int(dataRead[k])):
				$DeckDisplay.addCard(id)
		hasSaved = true
	else:
		print("Deck file is not valid")
		MessageManager.notify("Error loading deck\nop_code=" + str(error) + " : " + Deck.DECK_VALIDITY_TYPE.keys()[error])
		
	onFileLoadBackPressed()
		
func onFileSaveBackPressed():
	$SaveDisplay/Background/LineEdit.text = ""
	$SaveDisplay.visible = false
	
func onFileSaveButtonPressed():
	
	var fileName = $SaveDisplay/Background/LineEdit.text
	
	var error = Deck.verifyDeck($DeckDisplay.getDeckDataAsJSON())
	if error == Deck.DECK_VALIDITY_TYPE.VALID:
		var fileError = FileIO.writeToJSON(Settings.path, fileName, $DeckDisplay.getDeckData())
		if fileError != 0:
			MessageManager.notify("Error: File could not be saved")
			print("ERROR CODE WHEN WRITING TO FILE : " + str(fileError))
		else:
			print("Deck successfully saved")
			MessageManager.notify("Deck successfully saved")
			hasSaved = true
	else:
		MessageManager.notify("Error verifying deck\nop_code=" + str(error) + " : " + Deck.DECK_VALIDITY_TYPE.keys()[error])
	
	onFileSaveBackPressed()
		
var fileToDelete = ""
		
func onDeleteButtonPressed():
	$FileDisplay.visible = true
	$FileDisplay/ButtonHolder/Label.text = "Delete File"
		
	var files = []
	var dir = Directory.new()
	dir.open(Settings.path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") and file.ends_with("json"):
			files.append(file)
	dir.list_dir_end()
	
	for c in $FileDisplay/ButtonHolder.get_children():
		if c is Button and c.name != "BackButton":
			c.queue_free()
	for i in range(files.size()):
		var b = Button.new()
		$FileDisplay/ButtonHolder.add_child(b)
		b.text = str(files[i])
		b.connect("pressed", self, "onDeleteFileButtonPressed", [files[i]])
		$FileDisplay/ButtonHolder.move_child(b, i+1)
	$FileDisplay/ButtonHolder.set_anchors_and_margins_preset(Control.PRESET_CENTER)
	$FileDisplay/Background.rect_size = $FileDisplay/ButtonHolder.rect_size + Vector2(60, 20)
	$FileDisplay/Background.rect_position = $FileDisplay/ButtonHolder.rect_position - Vector2(30, 10)
	
func onDeleteFileButtonPressed(fileName : String):
	fileToDelete = fileName
	$FileDisplay.visible = false
	$ConfirmDeleteNode.visible = true
	$ConfirmDeleteNode/VBoxContainer/Label.text = "Are you sure you want to delete \n" + fileName
	
func onDeleteConfirmed():
	var dir = Directory.new()
	var error = dir.remove(Settings.path + "/" + fileToDelete)
	print(error)
	onDeleteBackPressed()
	
func onDeleteBackPressed():
	$ConfirmDeleteNode.visible = false
	fileToDelete = ""
	
func deckModified():
	hasSaved = false
	
func setCurrentPage(newPage : int):
	newPage = max(min(newPage, pages.size() - 1), 0)
	pages[currentPage].visible = false
	currentPage = newPage
	pages[newPage].visible = true
	
func getCurrentPage() -> int:
	return currentPage
	
func _input(event):
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.scancode == KEY_A:
			setCurrentPage(getCurrentPage() - 1)
		elif event.scancode == KEY_D:
			setCurrentPage(getCurrentPage() + 1)
			
	if event is InputEventMouseButton:
		if event.pressed and (event.button_index == 1 or event.button_index == 2):
			if slotViewing != null and slotReturning == null:
				yield(get_tree().create_timer(0.02), "timeout")
				if is_instance_valid(infoWindow):
					infoWindow.fadeOut()
				slotReturning = slotViewing
				slotViewing.cardNode.z_index -= 1
				slotViewing = null
				returnTimer = 0
