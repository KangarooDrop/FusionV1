extends Button


var selectedIndex := 0

var title := ""
var options := []
var keys := []

signal onSelected(button, key)

func _ready():
	#Waits until parent node has called its ready function
	yield(owner, "ready")
	
	NodeLoc.setButtonParams(self)
	
	$OptionDisplay.connect("onBackPressed", self, "onBackPressed")
	$OptionDisplay.connect("onOptionPressed", self, "onOptionPressed")
	$OptionDisplay.setOptions(title, options, keys)
	$OptionDisplay.hide()
	#$OptionDisplay.position = Vector2()
	
	if $OptionDisplay.optionList.size() > 0:
		$OptionDisplay/VBoxContainer/ScrollContainer/ButtonHolder.get_child(selectedIndex).emit_signal("pressed")

func onButtonPressed():
	$OptionDisplay.show()
	$OptionDisplay.global_position = get_viewport_rect().size / 2

func onOptionPressed(button : Button, key):
	selectedIndex = getIndex(button)
	emit_signal("onSelected", button, key)
	text = button.text
	onBackPressed()

func onBackPressed():
	$OptionDisplay.hide()

func getIndex(button : Button) -> int:
	return $OptionDisplay/VBoxContainer/ScrollContainer/ButtonHolder.get_children().find(button)
