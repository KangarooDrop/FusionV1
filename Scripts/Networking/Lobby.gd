extends Node


func hostButtonPressed():
	Server.host = true
	Server.online = true
	Server.startServer()
	
	$MultiplayerUI.visible = false
	$WaitLabel.visible = true
	
func joinButtonPressed():
	Server.ip = $MultiplayerUI/HBoxContainer2/LineEdit.text
	Server.connectToServer()
	Server.online = true
	
	$MultiplayerUI.visible = false
	$WaitLabel.visible = true
		
func startGame():
	var error = get_tree().change_scene("res://Scenes/main.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))
