extends Node2D

var fileName = "deck_test"
var path = "user://decks/"
	
var slotPageWidth = 4
var slotPageHeight = 3
var slotPageNum = slotPageWidth * slotPageHeight

var cardSlot = preload("res://Scenes/CardSlot.tscn")
var cardNode = preload("res://Scenes/CardNode.tscn")
onready var cardWidth = ListOfCards.cardBackground.get_width()
onready var cardHeight = ListOfCards.cardBackground.get_height()
var cardDists = 16

var currentPage := -1 setget setCurrentPage, getCurrentPage
var pages := []

var hasSaved = true

func _ready():
	var cardsToAdd := []
	for i in range(ListOfCards.cardList.size()):
		var c = ListOfCards.getCard(i)
		if c.tier <= 2:
			cardsToAdd.append(c)

	var remainder = slotPageNum - (cardsToAdd.size() % slotPageNum)
	for i in range(remainder):
		cardsToAdd.append(null)
			
	for i in range(cardsToAdd.size() / slotPageNum):
		var page = Node2D.new()
		page.name = "page_" + str(i)
		add_child(page)
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

func onSlotEnter(slot : CardSlot):
	pass
	
func onSlotExit(slot : CardSlot):
	pass
	
func slotClicked(slot : CardSlot, button_index : int, fromServer = false):
	if button_index == 1:
		if slot.cardNode != null:
			$DeckDisplay.addCard(slot.cardNode.card.UUID)
			return
	elif button_index == 2:
		if slot.cardNode != null:
			for i in range($DeckDisplay.data.size()):
				if $DeckDisplay.data[i].card.UUID == slot.cardNode.card.UUID:
					$DeckDisplay.removeCard(i)
					return
	
func onLoadPressed():
	confirmType = CONFIRM_TYPES.LOAD
	if not hasSaved:
		$ConfirmNode.visible = true
	else:
		onConfirmYesPressed()
		
func onSavePressed():
	confirmType = CONFIRM_TYPES.SAVE
	$ConfirmNode.visible = true
	
enum CONFIRM_TYPES {NONE, NEW, EXIT, LOAD, SAVE}
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
		
		
	elif confirmType == CONFIRM_TYPES.EXIT:
		var error = get_tree().change_scene("res://Scenes/StartupScreen.tscn")
		if error != 0:
			print("Error loading test1.tscn. Error Code = " + str(error))
			
			
	elif confirmType == CONFIRM_TYPES.LOAD:
		var dataRead = FileIO.readJSON(path + "/" + fileName + ".json")
		var error = Deck.verifyDeck(dataRead)
		print("Deck validity: " + str(error))
		if error == Deck.DECK_VALIDITY_TYPE.VALID:
			for k in dataRead.keys():
				var id = int(k)
				for i in range(int(dataRead[k])):
					$DeckDisplay.addCard(id)
			hasSaved = true
		else:
			print("Deck file is not valid")
			MessageManager.notify("Error loading deck\nop_code=" + str(error) + " : " + Deck.DECK_VALIDITY_TYPE.keys()[error])
			
			
	elif confirmType == CONFIRM_TYPES.SAVE:
		var error = Deck.verifyDeck($DeckDisplay.getDeckDataAsJSON())
		if error == Deck.DECK_VALIDITY_TYPE.VALID:
			var fileError = FileIO.writeToJSON(path, fileName, $DeckDisplay.getDeckData())
			if fileError != 0:
				print("ERROR CODE WHEN WRITING TO FILE : " + str(fileError))
			else:
				print("Deck successfully saved")
				MessageManager.notify("Deck successfully saved")
				hasSaved = true
		else:
			MessageManager.notify("Error verifying deck\nop_code=" + str(error) + " : " + Deck.DECK_VALIDITY_TYPE.keys()[error])
			
			
	$ConfirmNode.visible = false
	confirmType = CONFIRM_TYPES.NONE
	
func onConfirmNoPressed():
	$ConfirmNode.visible = false
	confirmType = CONFIRM_TYPES.NONE
		
func deckModified():
	hasSaved = false
	
func setCurrentPage(newPage : int):
	newPage = max(min(newPage, pages.size() - 1), 0)
	if newPage != currentPage:
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
