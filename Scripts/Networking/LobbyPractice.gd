extends Node

var popupUI = preload("res://Scenes/UI/PopupUI.tscn")

func _ready():
	var files = []
	var dir = Directory.new()
	dir.open(Settings.path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") and file.ends_with("json"):
			files.append(file)
	dir.list_dir_end()
	
	if files.size() > 0:
		for c in $DeckSelector/VBoxContainer.get_children():
			if c is Button and c.name != "BackButton":
				c.queue_free()
				c.get_parent().remove_child(c)
				
		for i in range(files.size()):
			var b = Button.new()
			$DeckSelector/VBoxContainer.add_child(b)
			b.text = str(files[i].get_basename())
			NodeLoc.setButtonParams(b)
			b.connect("pressed", self, "onFileButtonClicked", [files[i]])
			$DeckSelector/VBoxContainer.move_child(b, i+1)
		$DeckSelector/VBoxContainer.set_anchors_and_margins_preset(Control.PRESET_CENTER)
		$DeckSelector/Background.rect_size = $DeckSelector/VBoxContainer.rect_size + Vector2(60, 20)
		$DeckSelector/Background.rect_position = $DeckSelector/VBoxContainer.rect_position - Vector2(30, 10)
	else:
		MessageManager.notify("You must create a new deck before playing")
		onBackButtonClicked()
	
	
func onFileButtonClicked(fileName : String):
	
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
