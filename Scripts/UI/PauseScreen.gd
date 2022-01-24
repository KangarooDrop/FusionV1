extends Control
	
func onRestartPressed():
	if Server.online:
		if not get_node("/root/main/Board").playerRestart:
			if not get_node("/root/main/Board").opponentRestart:
				MessageManager.notify("Restart request sent to opponent")
			get_node("/root/main/Board").playerRestart = true
			Server.onRestart()
	else:
		MessageManager.notify("Opponent has already left the match")
	onBackPressed()

func onChangeDeckPressed():
	get_node("/root/main").onDeckChangePressed()
	onBackPressed()

func onSaveReplayPressed():
	get_node("/root/main/SaveNode").visible = true
	get_node("/root/main/SaveNode/SaveControl/LineEdit").grab_focus()
	onBackPressed()
	
func onBackPressed():
	visible = false

func onMainMenuPressed():
	if Server.online:
		Server.closeServer()
		Server.otherPlayerData = null
	var error = get_tree().change_scene("res://Scenes/StartupScreen.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))

func onExitPressed():
	get_tree().quit()
