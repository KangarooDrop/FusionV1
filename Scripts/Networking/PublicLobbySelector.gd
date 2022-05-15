extends Node

var pldScene = preload("res://Scenes/Networking/PublicLobbyData.tscn")

signal refreshPressed()
signal closePressed()
signal joinPressed(data)

export var lengths = [64, 128, 128, 128, 256+128]
var total
export var maxHeight = 256+64

onready var header = $VBoxContainer/PublicLobbyData
var backgroundBuffer = Vector2(16, 16)

# Called when the node enters the scene tree for the first time.
func _ready():
	total = 0
	for l in lengths:
		total += l
	
	header.initInfo("Username", "Version", "Players", "Game Info", lengths)
	header.joinButton.hide()
	
#	var testData = []
#	testData.append(["Noop1", "124", "3/4", "Constructed - Tournament"])
#	testData.append(["Ixzi", "poo", "1/2", "Draft - Winston - Tournament"])
#	testData.append(["Balformica", "nogirlz", "1/8", "Draft - Booster - Free Play"])
#	testData.append(["Chun", "help", "1/2", "Constructed - Free Play"])
#	testData.append(["Foobar", "AAAAAAAAAA", "4/4", "Constructed - Tournament"])
#	addAll(testData)
	
	resize()
	

func addEmptyText():
	var label = Label.new()
	NodeLoc.setLabelParams(label)
	label.text = "There are no public lobbies currently available"
	label.align = Label.ALIGN_CENTER
	label.rect_min_size = Vector2(total, 32)
	label.rect_size = Vector2()
	$VBoxContainer/ScrollContainer/VBoxContainer.add_child(label)
	resize()

func addAll(data):
	clearData()
	if data.size() == 0:
		addEmptyText()
	else:
		for datum in data:
			#Username, key, num_player, version, game_info
			#	-> 
			addData(datum[0], datum[3], datum[2], datum[4], datum[1])
	resize()

func addData(username, version, playerString, info, key) -> Node:
	var d = pldScene.instance()
	d.initInfo(username, version, playerString, info, lengths)
	d.joinButton.connect("pressed", self, "joinPressed", [[key]])
	$VBoxContainer/ScrollContainer/VBoxContainer.add_child(d)
	return d

func joinPressed(data):
	emit_signal("joinPressed", data)

func clearData():
	for c in $VBoxContainer/ScrollContainer/VBoxContainer.get_children():
		c.queue_free()

func resize():
	yield(get_tree(), "idle_frame")
	$VBoxContainer.set_anchors_and_margins_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)
	
	$VBoxContainer/ScrollContainer.rect_min_size = $VBoxContainer/ScrollContainer/VBoxContainer.rect_size
	$VBoxContainer/ScrollContainer.rect_min_size.y = min($VBoxContainer/ScrollContainer.rect_min_size.y, maxHeight)
	$VBoxContainer/ScrollContainer.rect_size = Vector2()
	
	yield(get_tree(), "idle_frame")
	
	$NinePatchRect.rect_position = $VBoxContainer.rect_position - backgroundBuffer / 2
	$NinePatchRect.rect_min_size = $VBoxContainer.rect_size + backgroundBuffer
	$NinePatchRect.rect_size = Vector2()
	
	$VBoxContainer/Toolbar/CloseButton.rect_position.x = $NinePatchRect.rect_size.x - backgroundBuffer.x - 32
	$VBoxContainer/Toolbar/RefreshButton.rect_position.x = $NinePatchRect.rect_size.x - backgroundBuffer.x - 64

func onClosePressed():
	emit_signal("closePressed")

func onRefreshPressed():
	emit_signal("refreshPressed")
