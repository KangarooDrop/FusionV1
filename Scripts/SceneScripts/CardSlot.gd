extends Node2D

class_name CardSlot

var disabled = false

var cardNode
var playerID = -1

enum ZONES {NONE, HAND, ENCHANTMENT, CREATURE, DECK, GRAVE, GRAVE_CARD}
var currentZone = ZONES.NONE
var isOpponent = false

var highlightOnSprite = preload("res://Art/card_slot_active.png")
var highlightOffSprite = preload("res://Art/card_slot.png")

onready var cardDisplay = load("res://Scripts/UI/CardDisplay.gd")

func _ready():
	if currentZone == ZONES.HAND:
		$SpotSprite.visible = false
	else:
		$SpotSprite.visible = true
	
	
	"""
	var globallyVis = true
	
	if not disabled and event is InputEventMouseButton and event.pressed and not event.is_echo():
		var mousePos = get_local_mouse_position()#get_viewport().get_mouse_position()
		var bounds = $Area2D/CollisionShape2D.shape.extents
		var inBounds = (mousePos.x >= -bounds.x) and (mousePos.x <= bounds.x) and (mousePos.y >= -bounds.y) and (mousePos.y <= bounds.y)
	
		var currentNode = self
		while currentNode != null:
			if "visible" in currentNode and not currentNode.visible:
				globallyVis = false
				break
			else:
				currentNode = currentNode.NodeLoc.getBoard()
			
		if globallyVis and inBounds and board != null and not disabled:
			yield(get_tree().create_timer(0.02), "timeout")
			print("EE! ", get_tree().is_input_handled())
			if not get_tree().is_input_handled():
				board.onSlotBeingClicked(self, event.button_index)
	"""

func shownToOpponent():
	if not isOpponent and currentZone == ZONES.HAND:
		$EyeSprite.visible = true

func mouseEnter():
	if not disabled:
		if get_parent() is cardDisplay:
			get_parent().onSlotEnter(self)
		else:
			var b = NodeLoc.getBoard()
			if is_instance_valid(b) and b.has_method("onSlotEnter"):
				b.onSlotEnter(self)
	
func mouseExit():
	if get_parent() is cardDisplay:
		get_parent().onSlotExit(self)
	else:
		var b = NodeLoc.getBoard()
		if is_instance_valid(b) and b.has_method("onSlotExit"):
			b.onSlotExit(self)

func getNeighbors() -> Array:
	var neighbors = []
	var index = get_index()
	if index < get_parent().get_child_count() - 1:
		var c = get_parent().get_child(index + 1)
		if c is get_script():
			neighbors.append(c)
	if index > 0:
		var c = get_parent().get_child(index - 1)
		if c is get_script():
			neighbors.append(c)
	return neighbors

func getAcross():
	if currentZone == ZONES.CREATURE and playerID >= 0:
		var board = NodeLoc.getBoard()
		var selfCreatures
		var otherCreatures
		for p in board.players:
			if p.UUID == playerID:
				selfCreatures = board.creatures[p.UUID]
			else:
				otherCreatures = board.creatures[p.UUID]
		if selfCreatures != null and otherCreatures != null:
			var index = selfCreatures.find(self)
			return otherCreatures[index]
	return null
		
func getClockwise():
	if currentZone == ZONES.CREATURE and playerID >= 0:
		var board = NodeLoc.getBoard()
		var index = board.creatures[playerID].find(self)
		
		for i in range(board.players.size()):
			if board.players[i].UUID == playerID:
				if i == 0:
					if index == 0:
						return board.creatures[board.players[(i+1) % board.players.size()].UUID][0]
					else:
						return board.creatures[playerID][index-1]
				else:
					if index == board.creatures[board.players[i].UUID].size() - 1:
						var creatures = board.creatures[board.players[(i+1) % board.players.size()].UUID]
						return creatures[creatures.size() - 1]
					else:
						return board.creatures[playerID][index+1]
		
	return null

func setHighlight(isHighlighted : bool):
	if isHighlighted:
		$SpotSprite.texture = highlightOnSprite
	else:
		$SpotSprite.texture = highlightOffSprite


func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if not disabled:
			if event.is_pressed():
				if get_parent() is cardDisplay:
					get_parent().onMouseDown(self, event.button_index)
				else:
					NodeLoc.getBoard().onMouseDown(self, event.button_index)
			elif not event.is_pressed():
				if get_parent() is cardDisplay:
					get_parent().onMouseUp(self, event.button_index)
				else:
					NodeLoc.getBoard().onMouseUp(self, event.button_index)
