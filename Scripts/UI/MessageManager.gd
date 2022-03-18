extends Control

var notif = preload("res://Scenes/UI/Message.tscn")

var yOff = 66
var moveTime = 0.25
var moving := {}

var canvas
var messageHolder
var versionLabel

func _ready():
	yield(get_tree(), "idle_frame")
	
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_margins_preset(Control.PRESET_WIDE)
	
	messageHolder = Control.new()
	messageHolder.name = "MessageHolder"
	add_child(messageHolder)
	messageHolder.set_anchors_and_margins_preset(Control.PRESET_CENTER_LEFT)
	
	versionLabel = Label.new()
	versionLabel.name = "VersionLabel"
	versionLabel.text = "Version: " + str(Settings.versionID)
	add_child(versionLabel)
	versionLabel.set_anchors_and_margins_preset(Control.PRESET_TOP_LEFT)
	versionLabel.rect_position += Vector2(8, 8)
	versionLabel.set("custom_colors/font_color", Color(0,0,0))
	

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
	var nLabel = n.get_node("NodeZ/Label")
	var nRect = n.get_node("NodeZ/Background")
	nLabel.rect_size.x = textLength
	nLabel.text = text
	messageHolder.add_child(n)
	n.rect_position.y -= 128
	
	nLabel.rect_position.x = margin + 6
	nLabel.rect_position.y = -nLabel.rect_size.y / 2
	nRect.rect_size = Vector2(textLength + margin * 2, nLabel.get_size().y + margin * 2)
	nRect.rect_position.y = -nRect.rect_size.y / 2
