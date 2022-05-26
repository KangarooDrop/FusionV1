extends Control

var notif = preload("res://Scenes/UI/Message.tscn")
var popupUI = preload("res://Scenes/UI/PopupUI.tscn")

var yOff = 66
var moveTime = 0.25
var moving := {}

onready var messageHolder = $MessageHolder
onready var versionLabel = $VersionLabel

func _ready():
	versionLabel.text = "Version: " + str(Settings.versionID)

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
	n.rect_position.y += 128
	
	nLabel.rect_position.x = margin + 6
	nLabel.rect_position.y = -nLabel.rect_size.y / 2
	nRect.rect_size = Vector2(textLength + margin * 2, nLabel.get_size().y + margin * 2)
	nRect.rect_position.y = -nRect.rect_size.y / 2

const POPUP_CLOSE_SELF = [0]

func createPopup(title : String, desc : String, buttonOptions := [POPUP_CLOSE_SELF]) -> PopupUI:
	var pop = popupUI.instance()
	
	for i in range(buttonOptions.size()):
		if buttonOptions[i] == POPUP_CLOSE_SELF:
			buttonOptions[i] = pop.GET_CLOSE_BUTTON()
	
	pop.init(title, desc, buttonOptions)
	$CanvasLayer/PopupHolder.add_child(pop)
	return pop
