extends Control

class_name DeckDisplayDataX

var count := 1
var card : Card
var margin = 4
var textLength = 300

func _ready():
	updateDisplay()
	
func updateDisplay(length = textLength):
	var text = _to_string()
	
	$Label.text = text
	$Label.rect_position.x = margin
	$Label.rect_size.x = length
	$Label.rect_position.y = -$Label.rect_size.y / 2
	
	$NinePatchRect.rect_size = Vector2(length + margin * 2, $Label.rect_size.y + margin * 2)
	$NinePatchRect.rect_position.y = -$NinePatchRect.rect_size.y / 2
	
	$Area2D/CollisionShape2D.position.x = $NinePatchRect.rect_size.x / 2
	$Area2D/CollisionShape2D.shape.extents = $NinePatchRect.rect_size / 2
	
func _to_string() -> String:
	if card != null:
		return card.name + " x" + str(count)
	else:
		return "error: none"
