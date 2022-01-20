extends Control

func _ready():
	var c1 = ListOfCards.getCard(0)
	var d1 = c1.serialize()
	print(d1)
	c1.power += 1
	var d2 = c1.serialize()
	print(d2)
	print(Card.areIdentical(d1, d2))

func onDeckEditPressed():
	var error = get_tree().change_scene("res://Scenes/DeckEditor.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))
	
func onLobbyPressed():
	Settings.gameMode = BoardMP.GAME_MODE.PLAYING
	var error = get_tree().change_scene("res://Scenes/Networking/Lobby.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))
	
func onReplayPressed():
	MessageManager.notify("Alert: This system is for debug. Proceed with caution")
	$FileDisplay.visible = true
	$VBoxContainer.visible = false
		
	var files = []
	var dir = Directory.new()
	dir.open(Settings.dumpPath)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") and file.ends_with("txt"):
			files.append(file)
	dir.list_dir_end()
	
	for c in $FileDisplay/ButtonHolder.get_children():
		if c is Button and c.name != "BackButton":
			c.queue_free()
	for i in range(files.size()):
		var b = Button.new()
		$FileDisplay/ButtonHolder.add_child(b)
		b.text = str(files[i])
		b.connect("pressed", self, "onReplayFilePressed", [files[i]])
		$FileDisplay/ButtonHolder.move_child(b, i+1)
	$FileDisplay/ButtonHolder.set_anchors_and_margins_preset(Control.PRESET_CENTER)
	$FileDisplay/Background.rect_size = $FileDisplay/ButtonHolder.rect_size + Vector2(60, 20)
	$FileDisplay/Background.rect_position = $FileDisplay/ButtonHolder.rect_position - Vector2(30, 10)
	
func onReplayFilePressed(fileName : String):
	Settings.dumpFile = fileName
	Settings.gameMode = BoardMP.GAME_MODE.REPLAY
	var error = get_tree().change_scene("res://Scenes/main.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))
	
func onReplayBackPressed():
	$FileDisplay.visible = false
	$VBoxContainer.visible = true
	
	
func onSettingsPressed():
	pass
	
func onExitPressed():
	get_tree().quit()
