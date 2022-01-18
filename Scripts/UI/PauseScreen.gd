extends Control
	
func onRestartPressed():
	if not get_node("/root/main/Board").playerRestart:
		if not get_node("/root/main/Board").opponentRestart:
			MessageManager.notify("Restart request sent to opponent")
		get_node("/root/main/Board").playerRestart = true
		Server.onRestart()
	onBackPressed()

func onBackPressed():
	visible = false

func onMainMenuPressed():
	if Server.online:
		Server.closeServer()
	var error = get_tree().change_scene("res://Scenes/StartupScreen.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))

func onExitPressed():
	get_tree().quit()
