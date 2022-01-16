extends Node

class_name CardSlot

var board
var cardNode
var playerID = -1

enum ZONES {NONE, HAND, ENCHANTMENT, CREATURE, GRAVE, DECK}
var currentZone = ZONES.NONE
var isOpponent = false

func _ready():
	if currentZone == ZONES.HAND:
		$SpotSprite.visible = false
	else:
		$SpotSprite.visible = true
	
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		board.slotClicked(self, event.button_index)
