extends Control

var showing = false
var spinTimer = 0
var spinMaxTime = 1
var off = 0.2
var spinRate = 2 * PI * 3 + randf() * off - off / 2
var scaleFinal = 5

func showWinLose(win : bool):
	if win:
		$Sprite.region_rect = Rect2(Vector2(0, 0), Vector2(64, 32))
	else:
		$Sprite.region_rect = Rect2(Vector2(0, 32), Vector2(64, 32))
	showing = true
	visible = true

func _physics_process(delta):
	if showing:
		spinTimer += delta
		
		$Sprite.rotation = spinTimer * spinRate
		var sc = lerp(0, scaleFinal, spinTimer / spinMaxTime)
		$Sprite.scale = Vector2(sc, sc)
		
		if spinTimer >= spinMaxTime:
			showing = false
