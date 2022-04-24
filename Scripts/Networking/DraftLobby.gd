extends Control

var popupUI = preload("res://Scenes/UI/PopupUI.tscn")
var playerLabel = preload("res://Scenes/Networking/PlayerLabel.tscn")

var pLabels := {}
var ids := []

var numMaxPlayers = -1

var startingUsername : String = ""

class_name DraftLobby

static func getDraftTypes():
	return \
		[["Winston", "res://Scenes/DraftWinston.tscn", "DraftTypeOptions/WinstonOptions"], 
		["Booster", "res://Scenes/DraftBooster.tscn", "DraftTypeOptions/BoosterOptions"],
		["Solomon", "res://Scenes/DraftSolomon.tscn", "DraftTypeOptions/SolomonOptions"],
#		["Test", "res://Scenes/main.tscn"]
	]

func _ready():
	numMaxPlayers = 8
	for s in getDraftTypes():
		$DraftTypeButton.add_item(s[0] + " Draft")
	
	$IPSet/HBoxContainer/LineEdit.text = str(Server.ip)
	
	$DraftTypeOptions/BoosterOptions/LineEdit.text = "3"
	$DraftTypeOptions/BoosterOptions/LineEdit._on_LineEdit_text_changed($DraftTypeOptions/BoosterOptions/LineEdit.text)
	
	$DraftTypeOptions/SolomonOptions/LineEdit.text = "3"
	$DraftTypeOptions/SolomonOptions/LineEdit._on_LineEdit_text_changed($DraftTypeOptions/SolomonOptions/LineEdit.text)
	
	startingUsername = Server.username
	
	BackgroundFusion.stop()
	
	$GPM/LineEdit.text = str(3)
	$GPM/LineEdit.oldtext = $GPM/LineEdit.text

###############################################

func hostButtonPressed():
	$MultiplayerUI.visible = false
	Server.host = true
	Server.online = true
	Server.startServer()
	$VBoxContainer.visible = true
	$Menu.visible = true
	$StartButton.visible = true
	$DraftTypeButton.visible = true
	addPlayer(-1, Server.username)
	
	$DraftTypeOptions.visible = true
	$DraftTypeButton.disabled = false
	$DraftTypeOptions/BoosterOptions/Label2.visible = true
	$DraftTypeOptions/BoosterOptions/LineEdit.visible = true
	$DraftTypeOptions/SolomonOptions/Label2.visible = true
	$DraftTypeOptions/SolomonOptions/LineEdit.visible = true
	$DraftTypeButton.select(0)
	$GPM.visible = true
	draftTypeSelected(0)
	
	MusicManager.playLobbyMusic()
	
func joinButtonPressed():
	$MultiplayerUI.visible = false
	$IPSet.visible = true

func backButtonPressed():
	var root = get_node("/root")
	var startup = load("res://Scenes/StartupScreen.tscn").instance()
	
	startup.onPlayPressed()
	root.add_child(startup)
	get_tree().current_scene = startup
	
	root.remove_child(self)
	queue_free()

###############################################

func ipBackButtonPressed():
	$MultiplayerUI.visible = true
	$IPSet.visible = false
	
func ipJoinButtonPressed():
	Server.ip = $IPSet/HBoxContainer/LineEdit.text
	Settings.writeToSettings()
	print("Draft joinging ip ", Server.ip)
	Server.online = true
	Server.connectToServer()
	$IPSet.visible = false
	
	$Menu.visible = true
	addPlayer(-1, Server.username)
	
	$DraftTypeButton.visible = true
	$DraftTypeOptions.visible = true
	$DraftTypeButton.disabled = true
	$DraftTypeOptions/BoosterOptions/Label2.visible = false
	$DraftTypeOptions/BoosterOptions/LineEdit.visible = false
	$DraftTypeOptions/SolomonOptions/Label2.visible = false
	$DraftTypeOptions/SolomonOptions/LineEdit.visible = false
	$GPM.visible = false
	
	MusicManager.playLobbyMusic()

###############################################

func lobbyBackPressed():
	Server.closeServer()
	$Menu.visible = false
	$VBoxContainer.visible = false
	$MultiplayerUI.visible = true
	$StartButton.visible = false
	$DraftTypeButton.visible = false
	$DraftTypeOptions.visible = false
	$GPM.visible = false
	for c in $DraftTypeOptions.get_children():
		c.visible = false
	
	while ids.size() > 0:
		removePlayer(ids[0])
		
	MusicManager.playMainMenuMusic()

###############################################

func joinedLobby(numMaxPlayers : int):
	self.numMaxPlayers = numMaxPlayers
	$VBoxContainer.visible = true
	setPlayerLabel()

func addPlayer(id, name):
	var pl
	if id != -1:
		pl = playerLabel.instance()
		pl.get_node("HBoxContainer/Label").text = name
		if Server.host and id != -1:
			pl.get_node("HBoxContainer/Button").visible = true
			NodeLoc.setButtonParams(pl.get_node("HBoxContainer/Button"))
			pl.get_node("HBoxContainer/Button").connect("pressed", Server, "kickUser", [id])
	else:
		pl = LineEdit.new()
		pl.text = name
		NodeLoc.setLineEditParams(pl)
		pl.connect("text_changed", self, "changeName")
	
	$VBoxContainer.add_child(pl)
	
	pLabels[id] = pl
	ids.append(id)
	
	setPlayerLabel()
	
	if Server.host:
		Server.setDraftType($DraftTypeButton.selected)

func changeName(newName : String):
	Server.setPlayerName(newName)

func editOwnName(username):
	pass
	#pLabels[-1].text = username

func editPlayerName(player_id : int, username : String):
	pLabels[player_id].get_node("HBoxContainer/Label").text = username

func removePlayer(id):
	if pLabels.has(id):
		$VBoxContainer.remove_child(pLabels[id])
		pLabels[id].queue_free()
		pLabels.erase(id)
		ids.erase(id)
		setPlayerLabel()
		$VBoxContainer.rect_size.y = 0

func setPlayerLabel():
	$VBoxContainer/Label.text = "Players ( " + str(ids.size()) + "/" + str(numMaxPlayers) + " ): "

###############################################

func startDraftButtonPressed():
	if $DraftTypeButton.selected == 2 and ids.size() != 2:
		var pop = popupUI.instance()
		pop.init("Solomon Draft", "There must be exactly 2 players to have a Solomon Draft", [["Close", pop, "close", []]])
		$PopupCenter.add_child(pop)
		return
	
	if int($GPM/LineEdit.text) < 1 or int($GPM/LineEdit.text) % 2 == 0:
		var pop = popupUI.instance()
		pop.init("Games Per Match Error", "The number of games per match must be odd and greater than zero", [["Close", pop, "close", []]])
		$PopupCenter.add_child(pop)
		return
	
	Server.setGamesPerMatch(int($GPM/LineEdit.text))
	
	var params = {}
	if $DraftTypeButton.selected == 1:
		params["num_boosters"] = $DraftTypeOptions/BoosterOptions/LineEdit.get_value()
	elif $DraftTypeButton.selected == 2:
		params["num_boosters"] = $DraftTypeOptions/SolomonOptions/LineEdit.get_value()
	Server.startDraft($DraftTypeButton.get_selected_id(), params)

func howToPlayWinstonPressed():
	var pop = popupUI.instance()
	var text = """Each players takes turns picking from the 3 available piles.
	
The piles are viewed one at a time and the player decides if they want to add that pile to their collection. 

If not, they add a card from the main stack to that pile and inspect the next one.

If none of the 3 piles are taken, add the top card of the main stack to your collection."""

	pop.init("Winston Draft", text, [["Back", pop, "close", []]])
	$PopupCenter.add_child(pop)

func howToPlayBoosterPressed():
	var pop = popupUI.instance()
	var text = """Each players is given 10 random cards (a booster).

Players choose 1 card from among them to add to their collection and pass the remaining cards to the next player.

This continues until all cards from that booster have been picked. 

Another booster is then opened (10 random cards) and the process repeats until all booster have been opened."""

	pop.init("Booster Draft", text, [["Back", pop, "close", []]])
	$PopupCenter.add_child(pop)

var lastDraftType = -1
func draftTypeSelected(index):
	if lastDraftType != -1:
		get_node(getDraftTypes()[lastDraftType][2]).visible = false
	get_node(getDraftTypes()[index][2]).visible = true
	lastDraftType = index
	
	if Server.host:
		Server.setDraftType(index)
	else:
		$DraftTypeButton.select(index)

func _exit_tree():
	if startingUsername != Server.username:
		Settings.writeToSettings()

func _input(event):
	if event is InputEventKey and event.is_pressed() and not event.is_echo() and event.scancode == KEY_ESCAPE:
		if $MultiplayerUI.visible:
			backButtonPressed()
		elif $IPSet.visible:
			ipBackButtonPressed()
		elif $Menu.visible:
			lobbyBackPressed()
