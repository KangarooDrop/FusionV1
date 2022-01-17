extends Control
	
func onRestartPressed():
	get_node("/root/main/Board").playerRestart = true
	Server.onRestart()
	onBackPressed()

func onBackPressed():
	visible = false

func onExitPressed():
	get_tree().quit()
