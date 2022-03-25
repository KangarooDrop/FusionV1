extends Control

var textToFileName := {}

func _ready():
	Settings.gameMode = Settings.GAME_MODE.NONE
	
	$SettingsPage/Shaders/SelectShaderButton.text = ShaderHandler.currentShader.get_file().get_basename().capitalize()

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

func onSettingsClose():
	$VBoxContainer.visible = true
