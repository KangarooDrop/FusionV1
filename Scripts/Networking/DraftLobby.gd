extends Control

var popupUI = preload("res://Scenes/UI/PopupUI.tscn")
var playerLabel = preload("res://Scenes/Networking/PlayerLabel.tscn")

var pLabels := []
var ids := []

var numMaxPlayers = -1

class_name DraftLobby

static func getDraftTypes():
	return \
		[["Winston", "res://Scenes/DraftWinston.tscn", "DraftTypeOptions/WinstonOptions"], 
		["Booster", "res://Scenes/DraftBooster.tscn", "DraftTypeOptions/BoosterOptions"],
#		["Test", "res://Scenes/main.tscn"]
	]

func _ready():
	numMaxPlayers = Server.MAX_PEERS + 1
	for s in getDraftTypes():
		$DraftTypeButton.add_item(s[0] + " Draft")
	
	$IPSet/HBoxContainer/LineEdit.text = str(Server.ip)
	$DraftTypeOptions/BoosterOptions/LineEdit.text = "3"
	$DraftTypeOptions/BoosterOptions/LineEdit._on_LineEdit_text_changed($DraftTypeOptions/BoosterOptions/LineEdit.text)

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
	$DraftTypeOptions/WinstonOptions/Label.visible = true
	$DraftTypeOptions/BoosterOptions/Label.visible = true
	$DraftTypeOptions/BoosterOptions/Label2.visible = true
	$DraftTypeOptions/BoosterOptions/LineEdit.visible = true
	$DraftTypeButton.select(0)
	draftTypeSelected(0)
	
func joinButtonPressed():
	$MultiplayerUI.visible = false
	$IPSet.visible = true

func backButtonPressed():
	var error = get_tree().change_scene("res://Scenes/StartupScreen.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))

###############################################

func ipBackButtonPressed():
	$MultiplayerUI.visible = true
	$IPSet.visible = false
	
func ipJoinButtonPressed():
	Server.ip = $IPSet/HBoxContainer/LineEdit.text
	Settings.writeToSettings()
	print(Server.ip)
	Server.online = true
	Server.connectToServer()
	$IPSet.visible = false
	
	$Menu.visible = true
	addPlayer(-1, Server.username)
	
	$DraftTypeButton.visible = true
	$DraftTypeOptions.visible = true
	$DraftTypeButton.disabled = true
	$DraftTypeOptions/WinstonOptions/Label.visible = false
	$DraftTypeOptions/BoosterOptions/Label.visible = false
	$DraftTypeOptions/BoosterOptions/Label2.visible = false
	$DraftTypeOptions/BoosterOptions/LineEdit.visible = false

###############################################

func lobbyBackPressed():
	Server.closeServer()
	$Menu.visible = false
	$VBoxContainer.visible = false
	$MultiplayerUI.visible = true
	$StartButton.visible = false
	$DraftTypeButton.visible = false
	$DraftTypeOptions.visible = false
	for c in $DraftTypeOptions.get_children():
		c.visible = false
	
	while ids.size() > 0:
		removePlayer(ids[0])

###############################################

func joinedLobby(numMaxPlayers : int):
	self.numMaxPlayers = numMaxPlayers
	$VBoxContainer.visible = true
	setPlayerLabel()

func addPlayer(id, name):
	var pl = playerLabel.instance()
	pl.get_node("HBoxContainer/Label").text = name
	if Server.host and id != -1:
		pl.get_node("HBoxContainer/Button").visible = true
		pl.get_node("HBoxContainer/Button").connect("pressed", Server, "kickUser", [id])
	
	$VBoxContainer.add_child(pl)
	
	pLabels.append(pl)
	ids.append(id)
	
	setPlayerLabel()
	
	if Server.host:
		Server.setDraftType($DraftTypeButton.selected)

func removePlayer(id):
	var index = ids.find(id)
	if index >= 0:
		$VBoxContainer.remove_child(pLabels[index])
		pLabels[index].queue_free()
		pLabels.remove(index)
		ids.remove(index)
	setPlayerLabel()
	$VBoxContainer.rect_size.y = 0

func setPlayerLabel():
	$VBoxContainer/Label.text = "Players ( " + str(ids.size()) + "/" + str(numMaxPlayers) + " ): "

###############################################

func startDraftButtonPressed():
	var params = {}
	if $DraftTypeButton.selected == 1:
		params["num_boosters"] = $DraftTypeOptions/BoosterOptions/LineEdit.get_value()
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
