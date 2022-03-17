extends Control

var fontTRES = preload("res://Fonts/FontNormal.tres")

var textToFileName := {}

func _ready():
	Settings.gameMode = Settings.GAME_MODE.NONE
	
	$SettingsPage/Shaders/Button.text = ShaderHandler.currentShader.get_file().get_basename().capitalize()

func onDeckEditPressed():
	var error = get_tree().change_scene("res://Scenes/DeckEditor.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))
	
func onPracticePressed():
	var error = get_tree().change_scene("res://Scenes/Networking/LobbyPractice.tscn")
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
	
func onSettingsPressed():
	$VBoxContainer.visible = false
	$SettingsPage.visible = true
	
func onExitPressed():
	get_tree().quit()

func shaderButtonPressed():
		
	$FileDisplay.visible = true
	$FileDisplay/ButtonHolder/Label.text = "Load File"
	
	var files = FileIO.getAllFiles(Settings.shaderPath)
	
	for c in $FileDisplay/ButtonHolder.get_children():
		if c is Button and c.name != "BackButton":
			$FileDisplay/ButtonHolder.remove_child(c)
			c.queue_free()
	for i in range(files.size()):
		if not files[i].begins_with(".") and files[i].ends_with("shader"):
			var b = Button.new()
			$FileDisplay/ButtonHolder.add_child(b)
			b.text = files[i].get_basename().capitalize()
			b.set("custom_fonts/font", fontTRES)
			b.connect("pressed", self, "onShaderLoadButtonPressed", [files[i]])
			$FileDisplay/ButtonHolder.move_child(b, i+1)
	$FileDisplay/ButtonHolder.set_anchors_and_margins_preset(Control.PRESET_CENTER)
	$FileDisplay/Background.rect_size = $FileDisplay/ButtonHolder.rect_size + Vector2(60, 20)
	$FileDisplay/Background.rect_position = $FileDisplay/ButtonHolder.rect_position - Vector2(30, 10)

func onShaderLoadButtonPressed(path):
	$SettingsPage/Shaders/Button.text = path.get_basename().capitalize()
	ShaderHandler.setShader(Settings.shaderPath + path)
	onShaderBackButtonPressed()

func onShaderBackButtonPressed():
	$FileDisplay.visible = false
