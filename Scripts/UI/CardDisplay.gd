extends Control

class_name CardDisplay

var cardSlotScene = preload("res://Scenes/CardSlot.tscn")
var cardNodeScene = preload("res://Scenes/CardNode.tscn")
onready var cardWidth = ListOfCards.cardBackground.get_width()
onready var cardHeight = ListOfCards.cardBackground.get_height()

var slots := []
var nodes := []

export(int) var totalWidth = 600

var maxVal = 1.5
var minVal = 1

export(bool) var canReorder := false
var cardHolding = null

var lastOff = -1

var clickedSlot : CardSlot = null
var mouseDown = false
var clickTimer = 0
var clickMaxTime = 0.18

#export(int) var totalWidth = 600
export(float) var viewMul = 0.75

var movingCards := []
export(int) var moveSpeed : int = 800

export(int) var z_index = 0
export(CardSlot.ZONES) var currentZone : int = CardSlot.ZONES.NONE
export(bool) var isOpponent = false

func _ready():
	myfunc()
	get_tree().get_root().connect("size_changed", self, "myfunc")

func myfunc():
	#totalWidth = get_viewport_rect().size.x * viewMul
	centerCards()

func centerCards():
	if slots.size() > 0:
		
		var dist = max(min(totalWidth / slots.size(), cardWidth * 2), 0)
		lastOff = dist
		var lastPosSlots := []
		var lastPosNodes := []
		
		for i in range(slots.size()):
			lastPosSlots.append(slots[i].global_position)
			lastPosNodes.append(nodes[i].global_position)
		
		BoardMP.centerNodes(slots, Vector2(), 0, dist)
		BoardMP.centerNodes(nodes, Vector2(), 0, dist)
		
		for i in range(slots.size()):
			var foundSlot = slots[i] == cardHolding
			for d in movingCards:
				if d[0] == slots[i]:
					if d[0] != cardHolding:
						d[1] = d[0].global_position
					foundSlot = true
			if not foundSlot:
				movingCards.append([slots[i], slots[i].global_position])
			
			slots[i].global_position = lastPosSlots[i]
			nodes[i].global_position = lastPosNodes[i]
					

func removeCard(index : int):
	if index >= 0 and index < slots.size():
		slots[index].queue_free()
		nodes[index].queue_free()
		slots.remove(index)
		nodes.remove(index)
		centerCards()

func addCard(card : Card) -> CardNode:
	var cardNode = cardNodeScene.instance()
	cardNode.card = card
	card.cardNode = cardNode
	addCardNode(cardNode)
	cardNode.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
	cardNode.setCardVisible(cardNode.getCardVisible())
	return cardNode

func addCardNode(cardNode : CardNode, moveIntoDisplay = false) -> CardNode:
	var cardSlot = cardSlotScene.instance()
	cardSlot.isOpponent = isOpponent
	cardSlot.currentZone = currentZone
	var lastPos = null
	if cardNode.is_inside_tree():
		lastPos = cardNode.global_position
	
	add_child(cardSlot)
	if is_instance_valid(cardNode.get_parent()):
		cardNode.get_parent().remove_child(cardNode)
	add_child(cardNode)
	
	if lastPos != null:
		cardSlot.global_position = lastPos
		cardNode.global_position = lastPos
	
	cardSlot.cardNode = cardNode
	cardNode.slot = cardSlot
	
	cardSlot.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
	
	slots.append(cardSlot)
	nodes.append(cardNode)
	
	cardSlot.get_node("SpotSprite").visible = false
	
	centerCards()
	
	return cardNode

func clear():
	for s in slots.duplicate():
		remove_child(s)
		s.queue_free()
	for n in nodes.duplicate():
		remove_child(n)
		n.queue_free()
	slots.clear()
	nodes.clear()
	movingCards.clear()

func _physics_process(delta):
	if movingCards.size() > 0:
		var toRemove := []
		for data in movingCards:
			if is_instance_valid(data[0]):
				var sp = moveSpeed * Settings.animationSpeed
				
				if (data[1] - data[0].global_position).length() <= sp / 50.0:
					data[0].global_position = data[1]
					data[0].cardNode.global_position = data[0].global_position
					toRemove.append(data)
				else:
					data[0].global_position += (data[1] - data[0].global_position).normalized() * sp * delta
					data[0].cardNode.global_position = data[0].global_position
			else:
				movingCards.erase(data)
				
		for data in toRemove:
			movingCards.erase(data)
	
	if mouseDownQueue.size() > 0:
		var highestZ = null
		for i in range(0, mouseDownQueue.size()):
			if (highestZ == null and is_instance_valid(mouseDownQueue[i].cardNode)) or (highestZ != null and is_instance_valid(highestZ.cardNode) and is_instance_valid(mouseDownQueue[i].cardNode) and mouseDownQueue[i].cardNode.z_index > highestZ.cardNode.z_index):
				var found = false
				for d in movingCards:
					if d[0] == mouseDownQueue[i]:
						found = true
				if not found:
					highestZ = mouseDownQueue[i]
		if highestZ != null:
			clickedSlot = highestZ
		mouseDownQueue.clear()
	
	if not canReorder and clickedSlot != null:
		get_parent().onMouseDown(clickedSlot, 1)
		clickedSlot = null
	
	if mouseDown:
		clickTimer += delta
		if clickTimer >= clickMaxTime:
			mouseDown = false
			cardHolding = clickedSlot
			clickedSlot = null
		
	
	if is_instance_valid(cardHolding):
		var oldIndex = slots.find(cardHolding)
		
		if oldIndex >= 0:
		
			var newIndex = int(int(cardHolding.position.x + (slots.size() / 2.0 * lastOff)) / lastOff)
			newIndex = min(newIndex, slots.size() - 1)
			newIndex = max(newIndex, 0)
			newIndex = max(newIndex, oldIndex-1)
			newIndex = min(newIndex, oldIndex+1)
			
			if newIndex != oldIndex:
				var tmp1 = slots[newIndex]
				var tmp2 = nodes[newIndex]
				slots[newIndex] = slots[oldIndex]
				nodes[newIndex] = nodes[oldIndex]
				slots[oldIndex] = tmp1
				nodes[oldIndex] = tmp2
				centerCards()
			
			cardHolding.cardNode.global_position = get_global_mouse_position()
			cardHolding.global_position = get_global_mouse_position()
			
	
	if slots.size() > 0:
		var mousePos = get_global_mouse_position()
		
		var dists   := []
		var indexes := []
		
		for i in range(slots.size()):
			var dist = (mousePos - slots[i].global_position).length()
			var dRatio = dist / totalWidth
			var maxValScaled = Settings.cardSlotScale * 1.5
			var minValScaled = Settings.cardSlotScale
			var val = lerp(minValScaled, maxValScaled, max(0, min(1, pow(1 - dRatio, 5))))
			val = stepify(val, 0.05)
			
			if not nodes[i].flipping:
				slots[i].scale = Vector2(val, val)
				nodes[i].scale = Vector2(val, val)
			
			var placed = false
			for j in range(dists.size()):
				if dist > dists[j]:
					dists.insert(j, dist)
					indexes.insert(j, i)
					placed = true
					break
			if not placed:
				dists.append(dist)
				indexes.append(i)
		
		for i in range(indexes.size()):
			nodes[indexes[i]].z_index = i + z_index
			slots[indexes[i]].z_index = i + z_index
	
	if mouseButtonReleased:
		if cardHolding != null:
			cardHolding = null
			centerCards()
		mouseButtonReleased = false
		mouseDown = false
		clickedSlot = null

func onSlotEnter(slot : CardSlot):
	get_parent().onSlotEnter(slot)
	
func onSlotExit(slot : CardSlot):
	get_parent().onSlotExit(slot)

var mouseDownQueue := []

func onMouseDown(slot : CardSlot, button_index : int):
	if canReorder and button_index == 1:
		mouseDownQueue.append(slot)
		mouseDown = true
		clickTimer = 0
	else:
		if button_index == 1:
			mouseDownQueue.append(slot)
		else:
			get_parent().onMouseDown(slot, button_index)

var mouseButtonReleased = false


func _input(event):
	if event is InputEventMouseButton and not event.is_pressed() and event.button_index == 1:
		mouseButtonReleased = true
		

func onMouseUp(slot : CardSlot, button_index : int):
	if button_index == 1:
		if mouseDown and is_instance_valid(clickedSlot) and slot == clickedSlot:
			get_parent().onMouseDown(slot, button_index)
			clickedSlot = null
			mouseButtonReleased = false

func setCards(cards : Array):
	clear()
	
	for c in cards:
		addCard(c)
