extends Control

class_name CardDisplay

var cardSlotScene = preload("res://Scenes/CardSlot.tscn")
var cardNodeScene = preload("res://Scenes/CardNode.tscn")
onready var cardWidth = ListOfCards.cardBackground.get_width()
onready var cardHeight = ListOfCards.cardBackground.get_height()

var slots := []
var nodes := []

var totalWidth = -1

var maxVal = 1.5
var minVal = 1
			
var board

export(bool) var canReorder := false
var cardHolding = null

var lastOff = -1

var clickedSlot : CardSlot = null
var mouseDown = false
var clickTimer = 0
var clickMaxTime = 0.18

var oldY = [-1]

export var viewMul = 0.75

var movingCards := []
var moveSpeed = 800

export var z_index = 0

func _ready():
	myfunc()
	get_tree().get_root().connect("size_changed", self, "myfunc")

func myfunc():
	totalWidth = get_viewport_rect().size.x * viewMul
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
			slots[i].global_position.y = lastPosSlots[i].y
			nodes[i].global_position.y = lastPosNodes[i].y
			for d in movingCards:
				if d[0] == slots[i]:
					d[1].x = slots[i].global_position.x
					slots[i].global_position.x = lastPosSlots[i].x
					nodes[i].global_position.x = lastPosNodes[i].x
					

func addCard(card : Card):
	var cardSlot = cardSlotScene.instance()
	var cardNode = cardNodeScene.instance()
	
	cardSlot.board = self
	cardNode.card = card
	
	cardSlot.cardNode = cardNode
	cardNode.slot = cardSlot
	
	cardSlot.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
	cardNode.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
	
	add_child(cardSlot)
	add_child(cardNode)
	
	slots.append(cardSlot)
	nodes.append(cardNode)
	
	cardSlot.get_node("SpotSprite").visible = false
	
	centerCards()

func addCardNode(cardNode : CardNode, moveIntoDisplay = false):
	var lastPos = cardNode.global_position
	var cardSlot = cardSlotScene.instance()
	
	cardSlot.board = self
	
	add_child(cardSlot)
	if is_instance_valid(cardNode.get_parent()):
		cardNode.get_parent().remove_child(cardNode)
	add_child(cardNode)
	
	cardSlot.cardNode = cardNode
	cardNode.slot = cardSlot
	
	cardSlot.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
	
	slots.append(cardSlot)
	nodes.append(cardNode)
	
	cardSlot.get_node("SpotSprite").visible = false
	
	centerCards()
	if moveIntoDisplay:
		movingCards.append([cardSlot, cardSlot.global_position])
		cardNode.global_position = lastPos
		cardSlot.global_position = lastPos

func clear():
	while slots.size() > 0:
		slots[0].queue_free()
		slots.remove(0)
	while nodes.size() > 0:
		nodes[0].queue_free()
		nodes.remove(0)

func _physics_process(delta):
	
	if movingCards.size() > 0:
		var toRemove := []
		for data in movingCards:
			if (data[1] - data[0].global_position).length() <= moveSpeed / 50.0:
				data[0].global_position = data[1]
				data[0].cardNode.global_position = data[0].global_position
				toRemove.append(data)
			else:
				data[0].global_position += (data[1] - data[0].global_position).normalized() * moveSpeed * delta
				data[0].cardNode.global_position = data[0].global_position
				
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
	
	if mouseDown:
		clickTimer += delta
		if clickTimer >= clickMaxTime:
			mouseDown = false
			if is_instance_valid(clickedSlot):
				oldY = [clickedSlot.global_position.y, clickedSlot.cardNode.global_position.y]
			cardHolding = clickedSlot
			clickedSlot = null
		
	
	if is_instance_valid(cardHolding):
		var oldIndex = slots.find(cardHolding)
		
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
			var val = lerp(minValScaled, maxValScaled, pow(1 - dRatio, 5))
			#val = stepify(val, 0.05)
			
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

func onSlotEnter(slot : CardSlot):
	if board != null:
		board.onSlotEnter(slot)
	
func onSlotExit(slot : CardSlot):
	if board != null:
		board.onSlotExit(slot)

var mouseDownQueue := []

func onMouseDown(slot : CardSlot, button_index : int):
	if canReorder and button_index == 1:
		mouseDownQueue.append(slot)
		mouseDown = true
		clickTimer = 0
	else:
		board.onMouseDown(slot, button_index)
	
func onMouseUp(slot : CardSlot, button_index : int):
	if button_index == 1:
		if mouseDown and is_instance_valid(clickedSlot) and slot == clickedSlot:
			board.onMouseDown(slot, button_index)
			clickedSlot = null
		
		if is_instance_valid(cardHolding) and slot == cardHolding:
			
			centerCards()
			cardHolding.global_position.y = oldY[0]
			cardHolding.cardNode.global_position.y = oldY[1]
			cardHolding = null
