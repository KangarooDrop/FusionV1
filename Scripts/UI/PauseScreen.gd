extends Control

var popupUI = preload("res://Scenes/UI/PopupUI.tscn")

var mmPop

func _ready():
	if not Server.online:
		$VBoxContainer/OpponentsButton.visible = false
	
	if Settings.matchType == Settings.MATCH_TYPE.FREE_PLAY:
		$VBoxContainer/ConcedeButton.visible = false
		
	elif Settings.matchType == Settings.MATCH_TYPE.TOURNAMENT:
		$VBoxContainer/ChangeDeckButton.visible = false
		$VBoxContainer/RestartButton.visible = false
		$VBoxContainer/OpponentsButton.visible = false

func onRestartPressed():
	if Server.online or Settings.gameMode == Settings.GAME_MODE.PRACTICE:
		if not get_node("/root/main/CenterControl/Board").playerRestart:
			if not get_node("/root/main/CenterControl/Board").opponentRestart:
				MessageManager.notify("Restart request sent to opponent")
			get_node("/root/main/CenterControl/Board").playerRestart = true
			Server.onRestart(Server.opponentID)
	else:
		MessageManager.notify("Opponent has already left the match")
	onBackPressed()

func onOpponentsPressed():
	$NinePatchRect.visible = false
	$VBoxContainer.visible = false
	$OpponentList.show()

func onOpponentsClose():
	$NinePatchRect.visible = true
	$VBoxContainer.visible = true

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
	mmPop = popupUI.instance()
	mmPop.init("Main Menu", "Are you sure you want to quit and return to the main menu?", [["Yes", self, "toMainMenu", []], ["Back", mmPop, "close", []]])
	get_parent().add_child(mmPop)
	
func toMainMenu():
	if Server.online:
		Server.closeServer()
	var error = get_tree().change_scene("res://Scenes/StartupScreen.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))

func onSettingsButtonClicked():
	$VBoxContainer.visible = false
	$SettingsPage.show()

func onSettingsClose():
	$VBoxContainer.visible = true

func onConcedePressed():
	var board = get_node("../../Board")
	Server.sendMessage(Server.opponentID, "Opponent has conceded")
	board.onConcede()

func show():
	.show()
	var offset = Vector2(64, 0)
	$NinePatchRect.rect_size = $VBoxContainer.rect_size + offset
	$NinePatchRect.rect_position = $VBoxContainer.rect_position - offset / 2
