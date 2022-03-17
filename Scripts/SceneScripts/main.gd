extends Node

var cardList_A : Array

var fontTRES = preload("res://Fonts/FontNormal.tres")

var deck_A : Deck
var hand_A : Array

export var board : NodePath 

func _ready():
	pass

func _input(event):
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.scancode == KEY_ESCAPE:
			if not $FileSelector.visible:
				$PauseNode/PauseMenu.visible = !$PauseNode/PauseMenu.visible
			else:
				onDeckChangeBackPressed()

func onDeckChangePressed():
	$PauseNode/PauseMenu.visible = false
	$FileSelector.visible = true
	
	var files = []
	var dir = Directory.new()
	dir.open(Settings.path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") and file.ends_with("json"):
			files.append(file)
	dir.list_dir_end()
	
	for c in $FileSelector/ButtonHolder.get_children():
		if c is Button and c.name != "BackButton":
			$FileSelector/ButtonHolder.remove_child(c)
			c.queue_free()
	for i in range(files.size()):
		var b = Button.new()
		$FileSelector/ButtonHolder.add_child(b)
		b.text = str(files[i].get_basename())
		b.set("custom_fonts/font", fontTRES)
		b.connect("pressed", self, "onDeckChangeButtonPressed", [files[i]])
		$FileSelector/ButtonHolder.move_child(b, i+1)
	$FileSelector/ButtonHolder.set_anchors_and_margins_preset(Control.PRESET_CENTER)
	$FileSelector/Background.rect_size = $FileSelector/ButtonHolder.rect_size + Vector2(60, 20)
	$FileSelector/Background.rect_position = $FileSelector/ButtonHolder.rect_position - Vector2(30, 10)

func onDeckChangeButtonPressed(fileName : String):
	onDeckChangeBackPressed()
	Settings.selectedDeck = fileName
	MessageManager.notify("Deck selected for next game")

func onDeckChangeBackPressed():
	$FileSelector.visible = false
	$PauseNode/PauseMenu.visible = true
