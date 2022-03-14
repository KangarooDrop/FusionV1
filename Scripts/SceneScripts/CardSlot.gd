extends Node2D

class_name CardSlot

var disabled = false

var board
var cardNode
var playerID = -1

enum ZONES {NONE, HAND, ENCHANTMENT, CREATURE, DECK}
var currentZone = ZONES.NONE
var isOpponent = false

var boundsMouse = false

var highlightOnSprite = preload("res://Art/card_slot_active.png")
var highlightOffSprite = preload("res://Art/card_slot.png")

func _ready():
	if currentZone == ZONES.HAND:
		$SpotSprite.visible = false
	else:
		$SpotSprite.visible = true

func _input(event):
	if event is InputEventMouseButton:
		if board != null and not disabled:
			if boundsMouse:
				if event.is_pressed():
					board.onMouseDown(self, event.button_index)
				elif not event.is_pressed():
					board.onMouseUp(self, event.button_index)
	
	
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
				currentNode = currentNode.get_parent()
			
		if globallyVis and inBounds and board != null and not disabled:
			yield(get_tree().create_timer(0.02), "timeout")
			print("EE! ", get_tree().is_input_handled())
			if not get_tree().is_input_handled():
				board.onSlotBeingClicked(self, event.button_index)
	"""
	
func mouseEnter():
	if board != null and not disabled:
		board.onSlotEnter(self)
	boundsMouse = true
	
func mouseExit():
	if board != null:
		board.onSlotExit(self)
	boundsMouse = false

func getNeighbors() -> Array:
	var neighbors = []
	var index = get_index()
	if index > 0:
		var c = get_parent().get_child(index - 1)
		if c is get_script():
			neighbors.append(c)
	if index < get_parent().get_child_count() - 1:
		var c = get_parent().get_child(index + 1)
		if c is get_script():
			neighbors.append(c)
	return neighbors

func setHighlight(isHighlighted : bool):
	if isHighlighted:
		$SpotSprite.texture = highlightOnSprite
	else:
		$SpotSprite.texture = highlightOffSprite
