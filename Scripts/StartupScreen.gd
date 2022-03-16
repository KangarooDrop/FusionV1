extends Control

var fontTRES = preload("res://Fonts/FontNormal.tres")

func _ready():
	Settings.gameMode = Settings.GAME_MODE.NONE
	for string in ShaderHandler.getShaderData():
		$SettingsPage/Shaders/OptionButton.add_item(string)
	$SettingsPage/Shaders/OptionButton.select(ShaderHandler.currentShader)

func onDeckEditPressed():
	var error = get_tree().change_scene("res://Scenes/DeckEditor.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))
	
func onLobbyPressed():
	Settings.gameMode = Settings.GAME_MODE.LOBBY_PLAY
	var error = get_tree().change_scene("res://Scenes/Networking/Lobby.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))

func onDraftPressed():
	Settings.gameMode = Settings.GAME_MODE.LOBBY_DRAFT
	var error = get_tree().change_scene("res://Scenes/Networking/DraftLobby.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))

func onReplayPressed():
	MessageManager.notify("Alert: This system is for debug purposes. Proceed with caution")
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
			c.get_parent().remove_child(c)
	for i in range(files.size()):
		var b = Button.new()
		$FileDisplay/ButtonHolder.add_child(b)
		b.text = str(files[i])
		b.set("custom_fonts/font", fontTRES)
		b.connect("pressed", self, "onReplayFilePressed", [files[i]])
		$FileDisplay/ButtonHolder.move_child(b, i+1)
	$FileDisplay/ButtonHolder.set_anchors_and_margins_preset(Control.PRESET_CENTER)
	$FileDisplay/Background.rect_size = $FileDisplay/ButtonHolder.rect_size + Vector2(60, 20)
	$FileDisplay/Background.rect_position = $FileDisplay/ButtonHolder.rect_position - Vector2(30, 10)
	
func onReplayFilePressed(fileName : String):
	Settings.dumpFile = fileName
	Settings.gameMode = Settings.GAME_MODE.REPLAY
	var error = get_tree().change_scene("res://Scenes/main.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))
	
func onReplayBackPressed():
	$FileDisplay.visible = false
	$VBoxContainer.visible = true
	
	
func onSettingsPressed():
	$VBoxContainer.visible = false
	$SettingsPage.visible = true
	
func onExitPressed():
	get_tree().quit()

func shaderButtonPressed(index):
	ShaderHandler.setShader(index)
