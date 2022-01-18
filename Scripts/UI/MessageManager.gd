extends Node

var notif = preload("res://Scenes/UI/Message.tscn")

var yOff = 66
var moveTime = 0.25
var moving := {}

var canvas
var messageHolder

func _ready():
	canvas = CanvasLayer.new()
	add_child(canvas)
	
	var control = Control.new()
	control.name = "MessageHolder"
	canvas.add_child(control)
	control.set_anchors_and_margins_preset(Control.PRESET_CENTER_LEFT)
	control.rect_position.x -= 128
	control.rect_position.y -= 128
	messageHolder = control
	

func _process(delta):
	var move = delta * yOff / moveTime
	for n in moving.keys():
		if is_instance_valid(n):
			n.rect_position.y += move
			moving[n] -= move
			if moving[n] <= 0:
				moving.erase(n)
		else:
			moving.erase(n)

func notify(text : String, textLength = 128, margin = 4):
	
	for n in messageHolder.get_children():
		if moving.has(n):
			moving[n] += yOff
		else:
			moving[n] = yOff
	
	var n = notif.instance()
	var nLabel = n.get_node("Label")
	var nRect = n.get_node("Background")
	nLabel.text = text
	messageHolder.add_child(n)
	
	nLabel.rect_position.x = margin + 6
	nLabel.rect_size.x = textLength
	nLabel.rect_position.y = -nLabel.rect_size.y / 2
	nRect.rect_size = Vector2(textLength + margin * 2, nLabel.rect_size.y + margin * 2)
	nRect.rect_position.y = -nRect.rect_size.y / 2
	
