extends Control
	
func onRestartPressed():
	if Server.online or Settings.gameMode == Settings.GAME_MODE.PRACTICE:
		if not get_node("/root/main/CenterControl/Board").playerRestart:
			if not get_node("/root/main/CenterControl/Board").opponentRestart:
				MessageManager.notify("Restart request sent to opponent")
			get_node("/root/main/CenterControl/Board").playerRestart = true
			Server.onRestart(get_node("/root/main/CenterControl/Board").opponentID)
	else:
		MessageManager.notify("Opponent has already left the match")
	onBackPressed()

func onChangeDeckPressed():
	get_node("/root/main").onDeckChangePressed()
	onBackPressed()

func onSaveReplayPressed():
	get_node("/root/main/CenterControl/SaveNode").visible = true
	get_node("/root/main/CenterControl/SaveNode/SaveControl/LineEdit").grab_focus()
	onBackPressed()
	
func onBackPressed():
	visible = false

func onMainMenuPressed():
	if Server.online:
		Server.closeServer()
	var error = get_tree().change_scene("res://Scenes/StartupScreen.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))

func onSettingsButtonClicked():
	$VBoxContainer.visible = false
	$SettingsPage.visible = true

func onSettingsClose():
	$VBoxContainer.visible = true
	
