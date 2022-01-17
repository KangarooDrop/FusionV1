extends Control
	
func onRestartPressed():
	get_node("/root/main/Board").playerRestart = true
	Server.onRestart()

func onBackPressed():
	visible = false

func onExitPressed():
	get_tree().quit()
