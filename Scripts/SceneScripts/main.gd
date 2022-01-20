extends Node

var cardList_A : Array


var deck_A : Deck
var hand_A : Array

export var board : NodePath 

func _ready():
	pass

func _input(event):
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.scancode == KEY_ESCAPE:
			$PauseNode/PauseMenu.visible = !$PauseNode/PauseMenu.visible

func onSaveReplayPressed():
	Settings.dumpFile = $SaveNode/SaveControl/LineEdit.text + ".txt"
	get_node("Board").saveReplay()
	$SaveNode/SaveControl/LineEdit.text = ""
	onSaveBackPressed()
	
func onSaveBackPressed():
	$SaveNode.visible = false
	
func onSaveEnter(s : String):
	onSaveBackPressed()
