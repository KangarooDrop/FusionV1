extends Node

var cardList_A : Array

var deck_A : Deck
var hand_A : Array

func _ready():
	pass

func _input(event):
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.scancode == KEY_ESCAPE:
			if $CenterControl/FileSelector.visible:
				onDeckChangeBackPressed()
			elif $CenterControl/PauseNode/PauseMenu/SettingsPage/FileDisplay.visible:
				$CenterControl/PauseNode/PauseMenu/SettingsPage.onShaderBackButtonPressed()
			elif $CenterControl/PauseNode/PauseMenu/SettingsPage.visible:
				$CenterControl/PauseNode/PauseMenu/SettingsPage.onBackPressed()
			else:
				if $CenterControl/PauseNode/PauseMenu.visible:
					$CenterControl/PauseNode/PauseMenu.hide()
				else:
					$CenterControl/PauseNode/PauseMenu.show()
				

func onDeckChangePressed():
	$CenterControl/PauseNode/PauseMenu.visible = false
	$CenterControl/FileSelector.visible = true
	
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
	
	for c in $CenterControl/FileSelector/ButtonHolder.get_children():
		if c is Button and c.name != "BackButton":
			$CenterControl/FileSelector/ButtonHolder.remove_child(c)
			c.queue_free()
	for i in range(files.size()):
		var b = Button.new()
		$CenterControl/FileSelector/ButtonHolder.add_child(b)
		b.text = str(files[i].get_basename())
		NodeLoc.setButtonParams(b)
		b.connect("pressed", self, "onDeckChangeButtonPressed", [files[i]])
		$CenterControl/FileSelector/ButtonHolder.move_child(b, i+1)
	$CenterControl/FileSelector/ButtonHolder.set_anchors_and_margins_preset(Control.PRESET_CENTER)
	$CenterControl/FileSelector/Background.rect_size = $CenterControl/FileSelector/ButtonHolder.rect_size + Vector2(60, 20)
	$CenterControl/FileSelector/Background.rect_position = $CenterControl/FileSelector/ButtonHolder.rect_position - Vector2(30, 10)

func onDeckChangeButtonPressed(fileName : String):
	onDeckChangeBackPressed()
	Settings.selectedDeck = fileName
	MessageManager.notify("Deck selected for next game")

func onDeckChangeBackPressed():
	$CenterControl/FileSelector.visible = false
	$CenterControl/PauseNode/PauseMenu.show()
