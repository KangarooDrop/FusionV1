extends Button

class_name OptionSelector

var initialized = false
var selectedIndex := 0

var title := ""
var options := []
var keys := []
var holder = self

signal onSelected(button, key)

var display
var buttonHolder
var displayScene = preload("res://Scenes/UI/OptionDisplay.tscn") 

func _ready():
	#Waits until parent node has called its ready function
	yield(owner, "ready")
	if not initialized:
		initOptions()

func initOptions():
	NodeLoc.setButtonParams(self)
	
	display = displayScene.instance()
	buttonHolder = display.get_node("VBoxContainer/ScrollContainer/ButtonHolder")
	display.name = "OptionDisplay"
	holder.add_child(display)
	
	display.connect("onBackPressed", self, "onBackPressed")
	display.connect("onOptionPressed", self, "onOptionPressed")
	display.setOptions(title, options, keys)
	display.hide()
	#display.position = Vector2()
	
	if display.optionList.size() > 0:
		buttonHolder.get_child(selectedIndex).emit_signal("pressed")
	
	initialized = true

func onButtonPressed():
	display.show()
	display.global_position = get_viewport_rect().size / 2

func onIndexPressed(index : int):
	var button = buttonHolder.get_child(index)
	var key = keys[index]
	onOptionPressed(button, key)

func onOptionPressed(button : Button, key):
	selectedIndex = getIndex(button)
	emit_signal("onSelected", button, key)
	text = button.text
	onBackPressed()

func onBackPressed():
	display.hide()

func getIndex(button : Button) -> int:
	return buttonHolder.get_children().find(button)
