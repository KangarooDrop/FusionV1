extends Control

var showing = false
var spinTimer = 0
var spinMaxTime = 1
var off = 0.2
var spinRate = 2 * PI * 3 + randf() * off - off / 2
var scaleFinal = 10

func showText(text, color):
	$Node2D/Label.text = text
	$Node2D/Label.set("custom_colors/font_color", color)
	showing = true
	visible = true

func _physics_process(delta):
	if showing:
		spinTimer += delta
		
		$Node2D.rotation = spinTimer * spinRate
		var sc = lerp(0, scaleFinal, spinTimer / spinMaxTime)
		$Node2D.scale = Vector2(sc, sc)
		
		if spinTimer >= spinMaxTime:
			showing = false
