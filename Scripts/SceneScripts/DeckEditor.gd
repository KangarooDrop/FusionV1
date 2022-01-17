extends Node2D

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
		
func onSavePressed():
	hasSaved = true
	
enum CONFIRM_TYPES {NONE, NEW, EXIT}
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
		print("NEW PAGE")
		
		for i in range(pages.size()):
			print(pages[i].visible)
	
	
func getCurrentPage() -> int:
	return currentPage
	
func _input(event):
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.scancode == KEY_A:
			setCurrentPage(getCurrentPage() - 1)
		elif event.scancode == KEY_D:
			setCurrentPage(getCurrentPage() + 1)
