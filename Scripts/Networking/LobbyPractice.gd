extends Node

var popupUI = preload("res://Scenes/UI/PopupUI.tscn")

func _ready():
	$FDCenter/OptionDisplay.connect("onBackPressed", self, "onBackButtonClicked")
	$FDCenter/OptionDisplay.connect("onOptionPressed", self, "onFileButtonClicked")
	$FDCenter/OptionDisplay.loadFiles("Select Deck", Settings.path, ["json"])
	if $FDCenter/OptionDisplay.optionList.size() == 0:
		MessageManager.notify("You must create a new deck before playing")
		onBackButtonClicked()
	
func onFileButtonClicked(button : Button, key):
	var fileName = key
	
	var path = Settings.path
	
	var dataRead = FileIO.readJSON(path + fileName)
	var dError = Deck.verifyDeck(dataRead)
	
	if dError != OK:
		var pop = popupUI.instance()
		pop.init("Error Loading Deck", "Error loading " + fileName + "\nop_code=" + str(dError) + " : " + Deck.DECK_VALIDITY_TYPE.keys()[dError], [["Close", pop, "close", []]])
		$PopupHolder.add_child(pop)
		pop.options[0].grab_focus()
		return
	
	Settings.selectedDeck = fileName
	Settings.gameMode = Settings.GAME_MODE.PRACTICE
	
	var error = get_tree().change_scene("res://Scenes/main.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))

func onBackButtonClicked():
	var root = get_node("/root")
	var startup = load("res://Scenes/StartupScreen.tscn").instance()
	
	startup.onPlayPressed()
	root.add_child(startup)
	get_tree().current_scene = startup
	
	root.remove_child(self)
	queue_free()

func _input(event):
	if event is InputEventKey and event.is_pressed() and not event.is_echo() and event.scancode == KEY_ESCAPE:
		onBackButtonClicked()
