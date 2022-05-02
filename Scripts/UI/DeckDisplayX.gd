extends Node2D

var deckDisplayData = preload("res://Scenes/UI/DeckDisplayDataX.tscn")
var cardSlot = preload("res://Scenes/CardSlot.tscn")
var cardNode = preload("res://Scenes/CardNode.tscn")
var hoverScene = preload("res://Scenes/UI/Hover.tscn")
onready var cardWidth = ListOfCards.cardBackground.get_width()
onready var cardHeight = ListOfCards.cardBackground.get_height()

var data := []
var total := -1 setget setTotal, getTotal
export var deckMax = -1

var parent

onready var holder = $Holder
onready var label = $Holder/Label
onready var vanguardLabel = $Holder/VanguardLabel

var hoverSlot = null
var hoverCard = null
var hoveringOn = null
var infoWindow = null

var buttonDownOn = null
var moving = false
var moveTimer = 0
var moveTimeMax = 0.2

var margin = 4

var canScroll = true
export(int) var maxHeight = 455
var currentHeight = 0

func _ready():
	setTotal(0)
	centerChildren()
	$ColorRect.rect_position.y = maxHeight

func _physics_process(delta):
	lastClosedHover = null
	
	if buttonDownOn != null:
		moveTimer += delta
		if moveTimer >= moveTimeMax:
			moving = true
	
	if moving:
		buttonDownOn.rect_global_position = get_global_mouse_position() - Vector2(buttonDownOn.get_node("NinePatchRect").rect_size.x / 2, 0)
		checkMove()

func checkMove():
	var pos = buttonDownOn.rect_position
	var extents = buttonDownOn.get_node("Area2D/CollisionShape2D").shape.extents
	var total = 0
	var index = 0
	var dataIndex = 0
	var lastIndex = data.find(buttonDownOn)
	var children = holder.get_children()
	for i in range(children.size()):
		if total >= pos.y - extents.y*2 and (index > 0) and children[i].visible:
			if index == 1 and holder.get_child(1) is DeckDisplayDataX:
				if buttonDownOn.card.rarity == Card.RARITY.VANGUARD:
					holder.move_child(holder.get_child(1), 3)
					holder.move_child(buttonDownOn, 1)
					swapData(dataIndex, lastIndex)
					centerChildren()
					break
			else:
				var indexCheck = 1
				if holder.get_child(1) is DeckDisplayDataX:
					indexCheck = 2
				if index != indexCheck or buttonDownOn.card.rarity == Card.RARITY.VANGUARD:
					holder.move_child(buttonDownOn, index)
					swapData(dataIndex, lastIndex)
					centerChildren()
					break
		if children[i] != label and children[i] != vanguardLabel:
			total += children[i].get_node("NinePatchRect").rect_size.y + margin
			index += 1
			dataIndex += 1
		else:
			total += children[i].rect_size.y + margin
			index += 1
		
		if i == children.size() - 1:
			holder.move_child(buttonDownOn, index)
			swapData(dataIndex, lastIndex)
			centerChildren()
			break

func swapData(index1 : int, index2 : int):
	if index1 >= 0 and index2 >= 0 and index1 < data.size() and index2 < data.size() and index1 != index2:
		var d1 = data[index1]
		data[index1] = data[index2]
		data[index2] = d1

func clearData():
	while(data.size() > 0):
		removeCard(0)

func setTotal(newTotal : int):
	if newTotal != total:
		total = newTotal
		if deckMax != -1:
			label.text = str(newTotal) + " / " + str(deckMax)
		else:
			label.text = ""
		if parent != null and parent.has_method("deckModified"):
			parent.deckModified()
		
		if total != -1 and total >= deckMax:
			label.set("custom_colors/font_color", Color.blueviolet)
		else:
			label.set("custom_colors/font_color", Color.black)
	
func getTotal() -> int:
	return total

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
	holder.add_child(d)
	data.append(d)
	d.get_node("Area2D").connect("input_event", self, "_on_Area2D_input_event", [d])
	setTotal(getTotal() + 1)
	
	if not holder.get_child(1) is DeckDisplayDataX and d.card.rarity == Card.RARITY.VANGUARD:
		holder.move_child(d, 1)
	
	centerChildren()
	return true

func centerChildren():
	var total = 0
	if holder.get_child(1) is DeckDisplayDataX:
		vanguardLabel.visible = true
	else:
		vanguardLabel.visible = false
	
	for c in holder.get_children():
		if c != label and c != vanguardLabel and c.visible:
			if c != buttonDownOn:
				c.rect_position.y = total + c.get_node("NinePatchRect").rect_size.y / 2
				c.rect_position.x = 0
			total += c.get_node("NinePatchRect").rect_size.y + margin
		else:
			c.rect_position.y = total
			c.rect_position.x = 0
			total += c.rect_size.y + margin
	
	currentHeight = total

func _on_Area2D_input_event(viewport, event, shape_idx, d):
	onDeckDataClicked(event, d)

func onDeckDataClicked(event : InputEvent, d):
	if event is InputEventMouseButton and not event.is_echo():
		if not event.is_pressed():
			var index = -1
			for i in range(data.size()):
				if data[i] == d:
					index = i
					break
			
			if index != -1 and event.button_index == 1 and buttonDownOn == d and not moving:
				return removeCard(index)
		else:
			if event.button_index == 1:
				buttonDownOn = d
			if event.button_index == 2:
				if not is_instance_valid(lastClosedHover) or lastClosedHover != d:
					openDeckDisplayHover(d)
	
	return false

func removeCard(index : int) -> bool:
	if index >= 0 and index < data.size():
		
		data[index].count -= 1
		if parent != null and parent.has_method("removeCard"):
			parent.removeCard(data[index].card.UUID)
			
		if data[index].count > 0:
			data[index].updateDisplay()
		else:
			if hoveringOn == data[index]:
				closeDeckDisplayHover()
			data[index].queue_free()
			holder.remove_child(data[index])
			data.remove(index)
		setTotal(getTotal() - 1)
		
		centerChildren()
		
		holder.rect_position.y = max(holder.rect_position.y, maxHeight - currentHeight - 16)
		holder.rect_position.y = min(holder.rect_position.y, 0)
		
		return true
	return false

var lastClosedHover = null
func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and not event.is_echo() and event.button_index == 2:
		if is_instance_valid(hoveringOn):
			lastClosedHover = hoveringOn
			closeDeckDisplayHover()
	
	if event is InputEventMouseButton and not event.is_pressed() and not event.is_echo() and event.button_index == 1:
		yield(get_tree(), "idle_frame")
		buttonDownOn = null
		moveTimer = 0
		moving = false
		centerChildren()
	
	if canScroll:
		if event is InputEventMouseButton and event.is_pressed():
			if event.button_index == BUTTON_WHEEL_DOWN:
				if currentHeight + holder.rect_position.y > maxHeight - 16:
					holder.rect_position.y = max(holder.rect_position.y - 10, maxHeight - currentHeight - 16)
					
			elif event.button_index == BUTTON_WHEEL_UP:
				if holder.rect_position.y < 0:
					holder.rect_position.y = min(holder.rect_position.y + 10, 0)

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
	hoverInst.z_index = 100
	hoverInst.flipped = true
	add_child(hoverInst)
	hoverInst.global_position = position
	hoverInst.setText(text)
	infoWindow = hoverInst

func getDeckData() -> Dictionary:
	var rtn = {"vanguard":{}, "cards":{}}
	for d in data:
		if d.card.rarity == Card.RARITY.VANGUARD:
			rtn["vanguard"][d.card.UUID] = d.count
		else:
			rtn["cards"][d.card.UUID] = d.count
	return rtn

func getDeckDataAsJSON() -> Dictionary:
	var rtn = {"vanguard":{}, "cards":{}}
	var data = getDeckData()
	for d in data.keys():
		for k in data[d].keys():
			rtn[d][str(k)] = float(data[d][k])
	return rtn
