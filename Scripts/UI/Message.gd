extends Control

var offset = 32

var timer = 0
var inTime = 0.5
var hangTime = 4

var width = 0

var startPos = null
var endPos = null

func _process(delta):
	if startPos == null:
		startPos = -$NodeZ/Background.rect_size.x * rect_scale.x * 1.5 - offset
	if endPos == null:
		endPos = offset - $NodeZ/Background.rect_size.x * rect_scale.x / 2
	
	timer += delta
	if timer < inTime:
		rect_position.x = lerp(startPos, endPos, timer / inTime)
	elif timer < inTime + hangTime:
		rect_position.x = endPos
	elif timer < inTime + hangTime + inTime:
		rect_position.x -= delta * ($NodeZ/Background.rect_size.x * rect_scale.x + offset) / inTime
	else:
		queue_free()
