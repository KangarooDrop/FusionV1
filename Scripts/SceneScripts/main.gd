extends Node

var cardList_A : Array

var deck_A : Deck
var hand_A : Array

func _ready():
	$CenterControl/OptionDisplay.connect("onBackPressed", self, "onDeckChangeBackPressed")
	$CenterControl/OptionDisplay.connect("onOptionPressed", self, "onDeckChangeButtonPressed")

func _input(event):
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.scancode == KEY_ESCAPE:
			if $CenterControl/OptionDisplay.visible:
				onDeckChangeBackPressed()
			elif $CenterControl/PauseNode/PauseMenu/SettingsPage/FDCenter/OptionDisplay.visible:
				$CenterControl/PauseNode/PauseMenu/SettingsPage.onShaderBackButtonPressed()
			elif $CenterControl/PauseNode/PauseMenu/SettingsPage.visible:
				$CenterControl/PauseNode/PauseMenu/SettingsPage.onBackPressed()
			elif $CenterControl/PauseNode/PauseMenu/OpponentList.visible:
				$CenterControl/PauseNode/PauseMenu/OpponentList.hide()
			elif $CenterControl/PauseNode/PauseMenu/OpponentList.visible:
				$CenterControl/PauseNode/PauseMenu/OpponentList.hide()
			elif is_instance_valid($CenterControl/PauseNode/PauseMenu.mmPop):
				$CenterControl/PauseNode/PauseMenu.mmPop.close()
			else:
				if $CenterControl/PauseNode/PauseMenu.visible:
					$CenterControl/PauseNode/PauseMenu.hide()
				else:
					$CenterControl/PauseNode/PauseMenu.show()
				

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
