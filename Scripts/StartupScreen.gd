extends Control

func onDeckEditPressed():
	var error = get_tree().change_scene("res://Scenes/DeckEditor.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))
	
func onLobbyPressed():
	var error = get_tree().change_scene("res://Scenes/Networking/Lobby.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))
	
func onSettingsPressed():
	pass
	
func onExitPressed():
	get_tree().quit()
