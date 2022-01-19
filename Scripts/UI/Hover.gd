extends Node2D

var text := ""

var fadeMaxTime = 0.3
var fadeTimer = fadeMaxTime
var fadingOut = false
var maxTextLen = 300
var flipped = false

func _ready():
	pass

func setText(text : String, margin = 4):
	var font = $Label.get_font("font")
	var textLength = font.get_string_size(text).x
	if textLength > maxTextLen:
		textLength = maxTextLen
	
	self.text = text
	$Label.text = text
	$Label.rect_position.x = margin + 6
	$Label.rect_size.x = textLength
	$Label.rect_position.y = -$Label.rect_size.y / 2
	$HoverBack.rect_size = Vector2(textLength + margin * 2, $Label.rect_size.y / 2 + margin * 2 + 16)
	$HoverBack.rect_position.y = -$HoverBack.rect_size.y / 2
	
	if flipped:
		scale.x = -1
		$Label.rect_scale.x = -1
		$Label.rect_position.x += $Label.rect_size.x
	
func fadeOut():
	fadingOut = true
	
func _physics_process(delta):
	if fadingOut:
		fadeTimer -= delta
		
		var c = Color(1, 1, 1, fadeTimer / fadeMaxTime)
		$HoverBack.modulate = c
		$TextureRect.modulate = c
		$Label.modulate = c
		
		if fadeTimer <= 0:
			queue_free()
