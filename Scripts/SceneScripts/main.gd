extends Control

var cardList_A : Array

var deck_A : Deck
var hand_A : Array

var boardMP = load("res://Scripts/Boards/BoardMP.gd")
var boardPuzzle = load("res://Scripts/Boards/BoardPuzzle.gd")
var boardPractice = load("res://Scripts/Boards/BoardMP.gd")

signal BoardScriptAdded(board)

func _ready():
	$CenterControl/OptionDisplay.connect("onBackPressed", self, "onDeckChangeBackPressed")
	$CenterControl/OptionDisplay.connect("onOptionPressed", self, "onDeckChangeButtonPressed")
	
	var b = get_node("CenterControl/Board")
	if Settings.gameMode == Settings.GAME_MODE.PUZZLE:
		b.set_script(boardPuzzle)
	elif Settings.gameMode == Settings.GAME_MODE.PRACTICE:
		b.set_script(boardPractice)
	else:
		b.set_script(boardMP)
	
	emit_signal("BoardScriptAdded", b)
	
	b.set_process(true)
	b.set_physics_process(true)
	b.set_process_input(true)
	b._ready()

func _input(event):
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.scancode == KEY_ESCAPE:
			if $CenterControl/LobbyChat.visible:
				$CenterControl/LobbyChat.fadingNode.fadeOut()
			elif $CenterControl/OptionDisplay.visible:
				onDeckChangeBackPressed()
			elif $Control/PauseNode/PauseMenu/SettingsPage/FDCenter/OptionDisplay.visible:
				$Control/PauseNode/PauseMenu/SettingsPage.onShaderBackButtonPressed()
			elif $Control/PauseNode/PauseMenu/SettingsPage.visible:
				$Control/PauseNode/PauseMenu/SettingsPage.onBackPressed()
			elif $Control/PauseNode/PauseMenu/OpponentList.visible:
				$Control/PauseNode/PauseMenu/OpponentList.hide()
			elif $Control/PauseNode/PauseMenu/OpponentList.visible:
				$Control/PauseNode/PauseMenu/OpponentList.hide()
			else:
				if $Control/PauseNode/PauseMenu.visible:
					$Control/PauseNode/PauseMenu.hide()
				else:
					$Control/PauseNode/PauseMenu.show()
				
		if event.scancode == KEY_ENTER:
			if not $CenterControl/LobbyChat.visible:
				$CenterControl/LobbyChat.fadingNode.fadeIn()

func onDeckChangePressed():
	var decks : Dictionary = SilentWolf.Players.player_data["decks"]
	var options : Array = decks.keys()
	options.sort()
	var keys : Array = []
	for d in options:
		keys.append(decks[d])
	$CenterControl/OptionDisplay.setOptions("Select Deck", options, keys)

func onDeckChangeButtonPressed(button : Button, key):
	onDeckChangeBackPressed()
	Settings.deckData = key
	MessageManager.notify("Deck selected for next game")

func onDeckChangeBackPressed():
	$CenterControl/OptionDisplay.hide()
	$CenterControl/PauseNode/PauseMenu.show()
