extends NinePatchRect

var offset = 32

var timer = 0
var inTime = 0.5
var hangTime = 4


func _process(delta):
	timer += delta
	if timer < inTime:
		rect_position.x = lerp(0, rect_size.x * rect_scale.x + offset, timer / inTime)
	elif timer < inTime + hangTime:
		rect_position.x = rect_size.x * rect_scale.x + offset
	elif timer < inTime + hangTime + inTime:
		rect_position.x -= delta * (rect_size.x * rect_scale.x + offset) / inTime
	else:
		queue_free()
