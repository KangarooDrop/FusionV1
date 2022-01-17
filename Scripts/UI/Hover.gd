extends Node2D

var text := ""

var fadeMaxTime = 0.3
var fadeTimer = fadeMaxTime
var fadingOut = false

func _ready():
	pass

func setText(text : String, margin = 4):
	var font = $Label.get_font("font")
	var textLength = font.get_string_size(text).x
	if textLength > 100:
		textLength = 100
	
	self.text = text
	$Label.text = text
	$Label.rect_position.x = margin + 6
	$Label.rect_size.x = textLength
	$HoverBack.rect_size = Vector2(textLength + margin * 2, $Label.rect_size.y + margin * 2)
	$HoverBack.rect_position.y = -$HoverBack.rect_size.y / 2
	print(textLength + margin * 2)
	
func fadeOut():
	fadingOut = true
	print($HoverBack.rect_size)
	
func _physics_process(delta):
	if fadingOut:
		fadeTimer -= delta
		
		var c = Color(1, 1, 1, fadeTimer / fadeMaxTime)
		$HoverBack.modulate = c
		$TextureRect.modulate = c
		$Label.modulate = c
		
		if fadeTimer >= fadeMaxTime:
			queue_free()
