extends Control

var count := 1
var card : Card
var margin = 4
var textLength = 300

func _ready():
	updateDisplay()
	
func updateDisplay():
	var text = _to_string()
	
	$Label.text = text
	$Label.rect_position.x = margin
	$Label.rect_size.x = textLength
	$Label.rect_position.y = -$Label.rect_size.y / 2
	$Button.rect_size = Vector2(textLength + margin * 2, $Label.rect_size.y + margin * 2)
	$Button.rect_position.y = -$Button.rect_size.y / 2
	
func _to_string() -> String:
	if card != null:
		return card.name + " x" + str(count)
	else:
		return "error: none"
