extends Control

export(String) var username = "" 
export(String) var session_id = ""
export(bool) var is_host = false


func _ready():
	Tournament.tree = null
	MusicManager.playMainMenuMusic()
	Settings.gameMode = Settings.GAME_MODE.NONE
	$SettingsPage/VBox/Shaders/SelectShaderButton.text = ShaderHandler.currentShader.get_file().get_basename().capitalize()
	
	BackgroundFusion.start()
	if Server.online:
		Server.closeServer()
	
	"""
	Tournament.startTournament(Tournament.genTournamentOrder([1, 2, 3, 4, 5, 6]))
	Tournament.trimBranches()
	print(Tournament.tree)
	Tournament.setWinner(5)
	print(Tournament.tree)
	print(Tournament.hasLost(5))
	
	print(Tournament.tree.getHeight())
	
#	print(Tournament.tree)
#	while Tournament.tree.root.data == -1:
#		Tournament.trimBranches()
#		print(Tournament.tree)
#		var i = randi() % 5 + 1
#		var opp = Tournament.getOpponent(i)
#		if opp >= 0:
#			Tournament.setWinner(opp)
#	print(Tournament.tree)
	"""


func onDeckEditPressed():
	var error = get_tree().change_scene("res://Scenes/DeckEditor.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))
	
func onPracticePressed():
	var error = get_tree().change_scene("res://Scenes/Networking/LobbyPractice.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))
	
func onSettingsPressed():
	$VBoxContainer.visible = false
	$SettingsPage.show()
	
func onExitPressed():
	get_tree().quit()

func onSettingsClose():
	$VBoxContainer.visible = true

func onPlayPressed():
	$VBoxContainer.visible = false
	$VBoxContainer2.visible = true

func onBackPressed():
	$VBoxContainer.visible = true
	$VBoxContainer2.visible = false
	$CreditsLabel.hide()
	$BackButton.hide()

func onCreditsPressed():
	$VBoxContainer.visible = false
	$CreditsLabel.show()
	$BackButton.show()

func onLobbyButtonPressed():
	var error = get_tree().change_scene("res://Scenes/Networking/LobbyX.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))

func onDirectButtonPressed():
	var error = get_tree().change_scene("res://Scenes/Networking/LobbyDirect.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))

func _input(event):
	if event is InputEventKey and event.is_pressed() and not event.is_echo() and event.scancode == KEY_ESCAPE:
		if $CreditsLabel.visible or $VBoxContainer2.visible:
			onBackPressed()
		elif $SettingsPage/FDCenter/OptionDisplay.visible:
			$SettingsPage.onShaderBackButtonPressed()
		elif $SettingsPage.visible:
			$SettingsPage.onBackPressed()

