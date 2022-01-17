extends Control
	
func onRestartPressed():
	get_node("/root/main/Board").playerRestart = true
	Server.onRestart()
	onBackPressed()

func onBackPressed():
	visible = false

func onLobbyPressed():
	var error = get_tree().change_scene("res://Scenes/Networking/Lobby.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))

func onExitPressed():
	get_tree().quit()
