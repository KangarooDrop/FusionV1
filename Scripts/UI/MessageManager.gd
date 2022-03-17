extends Node

var notif = preload("res://Scenes/UI/Message.tscn")

var yOff = 66
var moveTime = 0.25
var moving := {}

var canvas
var messageHolder

func _ready():
#	canvas = CanvasLayer.new()
#	add_child(canvas)
	
	var control = Control.new()
	control.name = "MessageHolder"
	add_child(control)
#	canvas.add_child(control)
	control.set_anchors_and_margins_preset(Control.PRESET_CENTER_LEFT)
	messageHolder = control
	
	var label = Label.new()
	label.text = "Version: " + str(Settings.versionID)
	add_child(label)
#	canvas.add_child(label)
	label.rect_position += Vector2(8, 8)
	label.set("custom_colors/font_color", Color(0,0,0))
	

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

func notify(text : String, textLength = 200, margin = 4):
	
	for n in messageHolder.get_children():
		if moving.has(n):
			moving[n] += yOff
		else:
			moving[n] = yOff
	
	var n = notif.instance()
	var nLabel = n.get_node("Label")
	var nRect = n.get_node("Background")
	nLabel.rect_size.x = textLength
	nLabel.text = text
	messageHolder.add_child(n)
	n.rect_position.y -= 128
	
	nLabel.rect_position.x = margin + 6
	nLabel.rect_position.y = -nLabel.rect_size.y / 2
	nRect.rect_size = Vector2(textLength + margin * 2, nLabel.get_size().y + margin * 2)
	nRect.rect_position.y = -nRect.rect_size.y / 2
	
