extends Node2D

var deckDisplayData = preload("res://Scenes/UI/DeckDisplayData.tscn")
var cardSlot = preload("res://Scenes/CardSlot.tscn")
var cardNode = preload("res://Scenes/CardNode.tscn")
var hoverScene = preload("res://Scenes/UI/Hover.tscn")
onready var cardWidth = ListOfCards.cardBackground.get_width()
onready var cardHeight = ListOfCards.cardBackground.get_height()

var data := []
var total := -1 setget setTotal, getTotal
export var deckMax = -1

var parent

func setTotal(newTotal : int):
	if newTotal != total:
		total = newTotal
		if deckMax != -1:
			$Label.text = str(newTotal) + " / " + str(deckMax)
		else:
			$Label.text = ""
		if parent != null and parent.has_method("deckModified"):
			parent.deckModified()
		
		if total != deckMax:
			$Label.set("custom_colors/font_color", Color.black)
		else:
			$Label.set("custom_colors/font_color", Color.blueviolet)
	
func getTotal() -> int:
	return total

func _ready():
	setTotal(0)

func _physics_process(delta):
	lastClosedHover = null

func clearData():
	while(data.size() > 0):
		removeCard(0)

func addCard(id : int) -> bool:
	for i in range(data.size()):
		if data[i].card.UUID == id:
			data[i].count += 1
			data[i].updateDisplay()
			setTotal(getTotal() + 1)
			return true
	
	var d = deckDisplayData.instance()
	d.card = ListOfCards.getCard(id)
	d.count = 1
	$VBoxContainer.add_child(d)
	data.append(d)
	d.get_node("Button").connect("gui_input", self, "onDeckDataClicked", [d])
	setTotal(getTotal() + 1)
	return true

var hoverSlot = null
var hoverCard = null
var hoveringOn = null
var infoWindow = null

func removeCard(index : int) -> bool:
	if index >= 0 and index < data.size():
		
		data[index].count -= 1
		parent.removeCard(data[index].card.UUID)
			
		if data[index].count > 0:
			data[index].updateDisplay()
		else:
			if hoveringOn == data[index]:
				closeDeckDisplayHover()
			data[index].queue_free()
			data.remove(index)
		setTotal(getTotal() - 1)
		
		return true
	return false

var lastClosedHover = null
func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and not event.is_echo() and event.button_index == 2:
		if is_instance_valid(hoveringOn):
			lastClosedHover = hoveringOn
			closeDeckDisplayHover()

func onDeckDataClicked(event : InputEvent, d):
	if event is InputEventMouseButton and event.is_pressed() and not event.is_echo():
		var index = -1
		for i in range(data.size()):
			if data[i] == d:
				index = i
				break
				
		if index != -1:
			match event.button_index:
				1:
					return removeCard(index)
					
				2:
					if not is_instance_valid(lastClosedHover) or lastClosedHover != d:
						openDeckDisplayHover(d)
	
	return false

func openDeckDisplayHover(button):
	hoveringOn = button
	
	hoverSlot = cardSlot.instance()
	hoverSlot.get_node("SpotSprite").visible = false
	hoverSlot.currentZone = CardSlot.ZONES.NONE
	add_child(hoverSlot)
	hoverSlot.global_position = Vector2(global_position.x - cardWidth * Settings.cardSlotScale *3.0/5, hoveringOn.rect_global_position.y)
	hoverSlot.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
	
	hoverCard = cardNode.instance()
	hoverCard.card = hoveringOn.card
	add_child(hoverCard)
	hoverCard.global_position = hoverSlot.global_position
	hoverCard.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
	
	hoverCard.slot = hoverSlot
	hoverSlot.cardNode = hoverCard
	
	createHoverNode(hoverCard.global_position + Vector2(-cardWidth * 0.5 * Settings.cardSlotScale, 0), hoveringOn.card.getHoverData())

func closeDeckDisplayHover(forceClose=false):
	if is_instance_valid(infoWindow):
		if infoWindow.close(forceClose):
			hoverCard.queue_free()
			hoverSlot.queue_free()
			hoveringOn = null
			hoverCard = null
			hoverSlot = null
			infoWindow = null

func createHoverNode(position : Vector2, text : String):
	var hoverInst = hoverScene.instance()
	hoverInst.z_index = 3
	hoverInst.flipped = true
	add_child(hoverInst)
	hoverInst.global_position = position
	hoverInst.setText(text)
	infoWindow = hoverInst

func onSlotEnter(cardSlot : CardSlot):
	pass
	
func onSlotExit(cardSlot : CardSlot):
	pass

func onMouseDown(cardSlot : CardSlot, button_index : int):
	pass

func onMouseUp(cardSlot : CardSlot, button_index : int):
	pass

func getDeckData() -> Dictionary:
	var rtn = {}
	for d in data:
		rtn[d.card.UUID] = d.count
	return rtn

func getDeckDataAsJSON() -> Dictionary:
	var rtn = {}
	var data = getDeckData()
	for d in data.keys():
		rtn[str(d)] = float(data[d])
	return rtn
