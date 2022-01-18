extends Node

var waitMaxTime = 0.6
var waitTimer = waitMaxTime
var waitNum = -1
var waitNumMax = 4

func _physics_process(delta):
	if $WaitLabel.visible:
		waitTimer += delta
		if waitTimer >= waitMaxTime:
			waitNum = (waitNum+1) % (waitNumMax + 1)
			waitTimer = 0
			$WaitLabel.text = "Waiting" + ".".repeat(waitNum)

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
		
func backButtonPressed():
	var error = get_tree().change_scene("res://Scenes/StartupScreen.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))
		
func startGame():
	var error = get_tree().change_scene("res://Scenes/main.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))

	
func _input(event):
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.scancode == KEY_ESCAPE:
			if Server.online:
				Server.closeServer()
				
				$MultiplayerUI.visible = true
				$WaitLabel.visible = false
				
