extends Node


var inLobby = false

var popupUI = preload("res://Scenes/UI/PopupUI.tscn")
var kickTex = preload("res://Art/UI/kick.png")

onready var lobbySettings = $LobbySettings

var messageTimer = 0

func _ready():
	Settings.gameMode = Settings.GAME_MODE.DIRECT
	BackgroundFusion.stop()
	MusicManager.playLobbyMusic()
	
	$FDCenter/OptionDisplay.connect("onOptionPressed", self, "onFileButtonClicked")
	
	$LobbySettings/VBoxContainer/HBoxContainer.hide()


func _process(delta):
	if messageTimer > 0:
		messageTimer -= delta


func setInLobby():
	if not inLobby:
		$Lobby/LeaveButton.text = "Leave Lobby"
		$Lobby/LineEdit.editable = false
		$Lobby/LineEdit2.editable = false
		$Lobby/JoinButton.disabled = true
		$Lobby/HostButton.disabled = true
		$Lobby/SendChatButton.disabled = false
		
		inLobby = true


func clearPlayers():
	var vbox = $Lobby/ScrollContainer/VBoxContainer
	for c in vbox.get_children():
		c.queue_free()
	
	
func _on_StartButton_pressed():
	var numOfPlayers = Server.playerIDs.size() + 1
	if numOfPlayers > 1:
		var params = getGameParams()
		if (params["game_type"] == Settings.GAME_TYPES.DRAFT and params["draft_type"] == Settings.DRAFT_TYPES.SOLOMON):
			if numOfPlayers != 2:
				print("Failure: Wrong player numbers")
				createPopup("Error Creating Lobby", "Failure: This game mode can only be played with exactly 2 players")
				return
		
		if params.has("games_per_match") and (params["games_per_match"] < 1 or params["games_per_match"] % 2 == 0):
			print("Failure: Bad games per match")
			createPopup("Error Creating Lobby", "Failure: The number of games per match must be greater than 0 and odd")
			return
		
		if params.has("num_boosters") and params["num_boosters"] < 3:
			print("Failure: Bad num boosters")
			createPopup("Error Creating Lobby", "Failure: Must draft with at least 3 booster packs")
			return
		
		for player_id in Server.playerIDs:
			Server.sendParams(player_id, getGameParams())
			Server.sendJoin(player_id)
		
		Settings.gameMode = Settings.GAME_MODE.LOBBY
		Server.receiveConfirmJoin()
	else:
		print("Failure: Not enough players")
		createPopup("Error Creating Lobby", "Failure: error:not_enough_players")


func _on_HostButton_pressed():
	Server.online = true
	Server.host = true
	var peers = $Lobby/LineEdit2.get_value()
	Server.startServer(Server.DEFAULT_PORT, peers)
	setInLobby()
	$Lobby/StartButton.disabled = false
	addUser(1, SilentWolf.Auth.logged_in_player)
	clearMessages()


func _on_JoinButton_pressed():
	if$Lobby/LineEdit.text != "":
		Server.online = true
		setInLobby()
		addUser(get_tree().get_network_unique_id(), SilentWolf.Auth.logged_in_player)
		$Lobby/LobbySettingsButton.disabled = true
		clearMessages()
		Server.connectToServer($Lobby/LineEdit.text)
	
	
func _on_LobbySettingsButton_pressed():
	lobbySettings.show()


func setOwnGameParams(gameParams : Dictionary):
	lobbySettings.setOwnGameParams(gameParams)


func getGameParams() -> Dictionary:
	return lobbySettings.getGameParams()


func createPopup(title : String, desc : String):
	var pop = popupUI.instance()
	pop.init(title, desc, [["Close", pop, "close", []]])
	$PopupHolder.add_child(pop)
	pop.options[0].grab_focus()


func _on_LeaveButton_pressed():
	if inLobby:
		clearPlayers()
		if Server.online:
			Server.closeServer()
		$Lobby/StartButton.disabled = true
		$Lobby/JoinButton.disabled = false
		$Lobby/HostButton.disabled = false
		$Lobby/SendChatButton.disabled = true
		$Lobby/LineEdit.editable = true
		$Lobby/LineEdit2.editable = true
		$Lobby/LeaveButton.text = "Main Menu"
		inLobby = false
		$Lobby/LobbySettingsButton.disabled = false
	else:
		var error = get_tree().change_scene("res://Scenes/StartupScreen.tscn")
		if error != 0:
			print("Error loading test1.tscn. Error Code = " + str(error))


func sendMessage(text = null):
	if text == null:
		text = $Lobby/LineEdit4.text
		
	if messageTimer >= 3:
		createPopup("Warning", "Slow down there, buckaroo! You're sending messages way too fast")
		return
	
	if text == "" or $Lobby/SendChatButton.disabled:
		return
	
	messageTimer += 1
	Server.sendChat(SilentWolf.Auth.logged_in_player + ": " + text)
	$Lobby/LineEdit4.text = ""


func receiveMessage(message : String):
	var label = Label.new()
	NodeLoc.setLabelParams(label)
	label.text = message
	$Lobby/ScrollContainer2/VBoxContainer.add_child(label)
	var scrollToBottom = ($Lobby/ScrollContainer2.get_v_scrollbar().max_value - $Lobby/ScrollContainer2.rect_size.y) - $Lobby/ScrollContainer2.scroll_vertical < 3
	if scrollToBottom:
		yield(get_tree(), "idle_frame")
		$Lobby/ScrollContainer2.scroll_vertical = $Lobby/ScrollContainer2.get_v_scrollbar().max_value


func clearMessages():
	for c in $Lobby/ScrollContainer2/VBoxContainer.get_children():
		c.queue_free()

func addUser(player_id, username):
		
	if not OS.is_window_focused():
		OS.request_attention()
				
	var vbox = $Lobby/ScrollContainer/VBoxContainer
	var label = Label.new()
	label.text = username
	NodeLoc.setLabelParams(label)
	vbox.add_child(label)
			
	if Server.host:
		if player_id != 1:
			print(player_id)
			var tb = TextureButton.new()
			tb.texture_normal = kickTex
			tb.texture_pressed = kickTex
			tb.texture_hover = kickTex
			label.add_child(tb)
			tb.rect_position = Vector2($Lobby/ScrollContainer.rect_size.x - kickTex.get_width() - 8, 2)
			tb.connect("pressed", self, "kickPlayer", [player_id])


func kickPlayer(player_id):
	Server.kickUser(player_id)


func removeUser(player_id, username):
		
	if not OS.is_window_focused():
		OS.request_attention()
	
	for c in $Lobby/ScrollContainer/VBoxContainer.get_children():
		if c is Label and c.text == username:
			c.queue_free()
			return

func startGame():
	$LeaveButton.show()
	openFileSelector()


func openFileSelector():
	var decks : Dictionary = SilentWolf.Players.player_data["decks"]
	var options : Array = decks.keys()
	var keys : Array = []
	for d in options:
		keys.append(decks[d])
	$FDCenter/OptionDisplay.setOptions("Select Deck", options, keys)
	
	$Lobby.hide()
	if $FDCenter/OptionDisplay.optionList.size() > 0:
		pass
	else:
		MessageManager.notify("You must create a new deck before playing")
		var error = get_tree().change_scene("res://Scenes/StartupScreen.tscn")
		if error != 0:
			print("Error loading test1.tscn. Error Code = " + str(error))

func onFileButtonClicked(button : Button, key):
	var dError = Deck.verifyDeck(key)
	
	if dError != OK:
		createPopup("Error Loading Deck", "Error loading " + button.text + "\nop_code=" + str(dError) + " : " + Deck.DECK_VALIDITY_TYPE.keys()[dError])
		return
	
	$FDCenter/OptionDisplay.hide()
	
	Settings.deckData = key
	
	if Settings.matchType == Settings.MATCH_TYPE.TOURNAMENT:
		Server.setReady(true)
		$LoadingWindow.visible = true
		$LoadingWindow/Label.text = "Waiting for opponents"
	
	elif Settings.matchType == Settings.MATCH_TYPE.FREE_PLAY:
		$OpponentList.show()

func _on_OpponentLeaveButton_pressed():
	var pop = popupUI.instance()
	pop.init("Main Menu", "Are you sure you want to quit and return to the main menu?", [["Yes", self, "toMainMenu", []], ["Back", pop, "close", []]])
	$PopupHolder.add_child(pop)
	pop.options[1].grab_focus()
	
func toMainMenu():
	if Server.online:
		Server.closeServer()
	var error = get_tree().change_scene("res://Scenes/StartupScreen.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))
