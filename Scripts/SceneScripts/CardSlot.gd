extends Node

class_name CardSlot

var board
var cardNode
var playerID = -1

enum ZONES {NONE, HAND, ENCHANTMENT, CREATURE, DECK}
var currentZone = ZONES.NONE
var isOpponent = false

func _ready():
	if currentZone == ZONES.HAND:
		$SpotSprite.visible = false
	else:
		$SpotSprite.visible = true
	
func mouseEnter():
	board.onSlotEnter(self)
	
func mouseExit():
	board.onSlotExit(self)
	
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		board.slotClicked(self, event.button_index, false)

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
