extends Node

var cardList_A : Array

var deck_A : Deck
var hand_A : Array

func _ready():
	$CenterControl/FileDisplay.connect("onBackPressed", self, "onDeckChangeBackPressed")
	$CenterControl/FileDisplay.connect("onFilePressed", self, "onDeckChangeButtonPressed")

func _input(event):
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.scancode == KEY_ESCAPE:
			if $CenterControl/FileDisplay.visible:
				onDeckChangeBackPressed()
			elif $CenterControl/PauseNode/PauseMenu/SettingsPage/FDCenter/FileDisplay.visible:
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
	$CenterControl/FileDisplay.loadFiles("Select Deck", Settings.path, ["json"])

func onDeckChangeButtonPressed(fileName : String):
	onDeckChangeBackPressed()
	Settings.selectedDeck = fileName
	MessageManager.notify("Deck selected for next game")

func onDeckChangeBackPressed():
	$CenterControl/FileDisplay.hide()
	$CenterControl/PauseNode/PauseMenu.show()
