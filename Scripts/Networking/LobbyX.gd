extends Node

var inLobby = false

var popupUI = preload("res://Scenes/UI/PopupUI.tscn")

func _ready():
	Settings.gameMode = Settings.GAME_MODE.LOBBY_PLAY
	$RabidHolePuncher.connect("holepunch_progress_update", self, "holepunch_progress_update")
	$RabidHolePuncher.connect("holepunch_failure", self, "holepunch_failure")
	$RabidHolePuncher.connect("holepunch_success", self, "holepunch_success")

func setInLobby():
	if not inLobby:
		$Lobby/LeaveButton.text = "Leave Lobby"
		$Lobby/LineEdit.editable = false
		$Lobby/JoinButton.visible = false
		$Lobby/HostButton.visible = false
		
		inLobby = true

func holepunch_progress_update(type, session_name, player_names):
	print(type, "  ", session_name, "  ", player_names)
	
	if type == "session_created":
		if $RabidHolePuncher.is_host():
			$Lobby/StartButton.visible = true
			
	if type == "session_created" or type == "session_updated":
		clearPlayers()
		var vbox = $Lobby/ScrollContainer/VBoxContainer
		for name in player_names:
			var label = Label.new()
			label.text = name
			NodeLoc.setLabelParams(label)
			vbox.add_child(label)
	
	if type == "starting_session":
		$Lobby/StartButton.visible = false

func clearPlayers():
	var vbox = $Lobby/ScrollContainer/VBoxContainer
	for c in vbox.get_children():
		c.queue_free()
	

func holepunch_failure(error):
	if inLobby:
		clearPlayers()
		_on_LeaveButton_pressed()
		
	if error != "error:player_exited_session":
		print("Failure: ", error)
		var pop = popupUI.instance()
		pop.init("Error Creating Lobby", "Failure: " + str(error), [["Close", pop, "close", []]])
		$PopupHolder.add_child(pop)
		pop.options[0].grab_focus()

func holepunch_success(self_port, host_ip, host_port):
	print("Success: ", self_port, "  ", host_ip, "  ", host_port)
	
	Server.online = true
	if host_ip == null:
		Server.host = true
		Server.startServer(self_port)
	else:
		Server.connectToServer(host_ip, host_port, self_port)

func playerConnected(player_id : int):
	print("player connected: ", player_id)
	
func playerDisconnected(player_id : int):
	print("player dc'd: ", player_id)
	
func _OnConnectFailed():
	print("failed to connect to server")

func _OnConnectSucceeded():
	print("connected to server")

func _Server_Disconnected():
	print("Server diconnected")

func _exit_tree():
	$RabidHolePuncher.exit_session()
#	Server.closeServer()

func _on_HostButton_pressed():
	if not Input.is_action_pressed("ui_up"):
		setInLobby()
		$RabidHolePuncher.create_session($Lobby/LineEdit.text, Server.username, 3)
	else:
		holepunch_success(25565, null, null)

func _on_JoinButton_pressed():
	if not Input.is_action_pressed("ui_up"):
		setInLobby()
		$RabidHolePuncher.join_session($Lobby/LineEdit.text, Server.username, 3)
	else:
		holepunch_success(0, "127.0.0.1", 25565)

func _on_StartButton_pressed():
	$RabidHolePuncher.start_session()

func _on_LeaveButton_pressed():
	if inLobby:
		clearPlayers()
		_exit_tree()
		if Server.online:
			Server.closeServer()
		$Lobby/StartButton.visible = false
		$Lobby/JoinButton.visible = true
		$Lobby/HostButton.visible = true
		$Lobby/LineEdit.editable = true
		$Lobby/LeaveButton.text = "Main Menu"
		inLobby = false
	else:
		var error = get_tree().change_scene("res://Scenes/StartupScreen.tscn")
		if error != 0:
			print("Error loading test1.tscn. Error Code = " + str(error))

func startGame():
	openFileSelector()

func openFileSelector():
	$DeckSelector.visible = true
	$Lobby.visible = false
		
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
		$DeckSelector.visible = false
		$MultiplayerUI.visible = true

	
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
	
	$DeckSelector.visible = false
	
	Settings.selectedDeck = fileName
	
	var error = get_tree().change_scene("res://Scenes/main.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))
