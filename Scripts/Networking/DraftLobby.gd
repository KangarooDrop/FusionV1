extends Control

var playerLabel = preload("res://Scenes/Networking/PlayerLabel.tscn")

var pLabels := []
var ids := []

var numMaxPlayers = -1

class_name DraftLobby

static func getDraftTypes():
	return \
		[["Winston", "res://Scenes/DraftWinston.tscn"], 
		["Booster", "res://Scenes/DraftBooster.tscn"]
	]

func _ready():
	numMaxPlayers = Server.MAX_PEERS + 1
	for s in getDraftTypes():
		$DraftTypeButton.add_item(s[0] + " Draft")
	$DraftTypeButton.select(0)

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
	print(Server.ip)
	Server.online = true
	Server.connectToServer()
	$IPSet.visible = false
	
	$Menu.visible = true
	addPlayer(-1, Server.username)

###############################################

func lobbyBackPressed():
	Server.closeServer()
	$Menu.visible = false
	$VBoxContainer.visible = false
	$MultiplayerUI.visible = true
	$StartButton.visible = false
	$DraftTypeButton.visible = false
	
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
	Server.startDraft($DraftTypeButton.get_selected_id())
	
