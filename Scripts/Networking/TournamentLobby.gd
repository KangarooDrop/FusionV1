extends Node

class_name TournamentLobby

var popupUI = preload("res://Scenes/UI/PopupUI.tscn")

enum STATUS {NONE, WAITING, LOSE, WIN, SETTING_UP}
var currentStatus : int = STATUS.NONE

var waitingTimer = 0
var waitingMaxTime = 1
var waitingNum = 0

var idToLabel := {}

func _ready():
	Server.opponentID = -1
	MusicManager.playLobbyMusic()
	#tournyTest()
	if Tournament.tree != null:
		checkNextGame()

func tournyTest():
	var players = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]
	Tournament.startTournament(Tournament.genTournamentOrder(players))
	while Tournament.tree.root.data == -1:
		Tournament.trimBranches()
		var i = players[randi() % players.size()]
		if not Tournament.hasLost(i):
			var opp = Tournament.getOpponent(i)
			if opp >= 0:
				Tournament.setWinner(i)

func _physics_process(delta):
	if currentStatus == STATUS.WAITING:
		waitingTimer += delta
		if waitingTimer >= waitingMaxTime:
			waitingTimer = 0
			waitingNum += 1
			if waitingNum >= 4:
				waitingNum = 0
			$Label.text = "Waiting For Opponent" + ".".repeat(waitingNum)

func generateBracket():
	print("Generating bracket display")
	
	for c in $BracketHolder.get_children():
		$BracketHolder.remove_child(c)
	
	var screenSize = get_viewport().get_visible_rect().size
	var bracketSize = screenSize * 0.6
	
	var rr = ReferenceRect.new()
	rr.rect_min_size = bracketSize
	rr.border_color = Color.black
	rr.border_width = 2
	rr.editor_only = false
	$BracketHolder.add_child(rr)
	rr.set_anchors_and_margins_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)
	#rr.rect_position.y += 32
	var cr = ColorRect.new()
	cr.rect_min_size = rr.rect_min_size
	cr.color = Color.white
	$BracketHolder.add_child(cr)
	cr.rect_position = rr.rect_position
	
	var treeHeight = Tournament.tree.getHeight()
	
	var treeSize = bracketSize * 0.8
	var linkSize = Vector2(treeSize.x / (treeHeight), treeSize.y / (pow(2, treeHeight - 1) - 1) * (.5 if treeHeight == 2 else 1))
	
	var deltaW = linkSize.x
	var deltaH = linkSize.y
	var labelWidth = 90
	
	for i in range(treeHeight-1, -1, -1):
		var nodes = Tournament.tree.getNodesAtHeight(i)
		for j in range(nodes.size()):
			var a = treeHeight - i
			var b = j
			var yVal = b * pow(2, a) + pow(2, a-1) - 0.5
			
			var label = Label.new()
			$BracketHolder.add_child(label)
			label.add_color_override("font_color", Color(0,0,0))
			label.rect_position = Vector2((treeHeight-i-1) * deltaW, yVal * deltaH/2) - treeSize / 2
			label.rect_min_size.x = labelWidth
			label.rect_size.x = labelWidth
			label.clip_text = true
			
			if Server.playerNames.has(nodes[j].data):
				label.text = Server.playerNames[nodes[j].data]
			elif nodes[j].data == get_tree().get_network_unique_id():
				label.text = SilentWolf.Auth.logged_in_player
			elif nodes[j].data == -1:
				label.text = "                 "
			else:
				label.text = "NA " + str(nodes[j].data % 100)
				print("no_idea=", nodes[j].data)
			
			idToLabel[nodes[j].data] = label
				
			var border = Vector2(4, 4)
			var r = ReferenceRect.new()
			r.rect_min_size = Vector2(labelWidth, label.rect_size.y) + border * 2
			r.border_color = Color.black
			r.border_width = 1
			r.editor_only = false
			$BracketHolder.add_child(r)
			r.rect_position = label.rect_position - border
			
			var distW = deltaW - labelWidth - border.x * 2
			var line = Line2D.new()
			line.default_color = Color.black
			line.width = 1
			line.points = PoolVector2Array([Vector2(0, 0), Vector2(distW/2, 0)])
			line.position = label.rect_position + Vector2(labelWidth + border.x, label.rect_size.y / 2)
			$BracketHolder.add_child(line)
			
			if j % 2 == 0 and i > 0:
				line = Line2D.new()
				line.default_color = Color.black
				line.width = 1
				line.points = PoolVector2Array([Vector2(0, 0), Vector2(0, deltaH * pow(2, treeHeight-i-1))])
				line.position = label.rect_position + Vector2(labelWidth + border.x + distW/2, label.rect_size.y / 2)
				$BracketHolder.add_child(line)
				
				line = Line2D.new()
				line.default_color = Color.black
				line.width = 1
				line.points = PoolVector2Array([Vector2(0, 0), Vector2(distW/2, 0)])
				line.position = label.rect_position + Vector2(labelWidth + border.x + distW/2, label.rect_size.y / 2 + deltaH / 2 * pow(2, treeHeight-i-1))
				$BracketHolder.add_child(line)
	

func checkNextGame():
	print("Checking If Next Game Available")
	generateBracket()
	
	var id = get_tree().get_network_unique_id()
	var opponentID = Tournament.getOpponent(id)
		
	if Tournament.tree.root.data == id:
		currentStatus = STATUS.WIN
		$Label.text = "You Win!"
	elif Tournament.hasLost:
		currentStatus = STATUS.LOSE
		$Label.text = "You Lose!"
	elif Tournament.isWaiting(id):
		currentStatus = STATUS.WAITING
		$Label.text = "Waiting For Opponent"
	else:
		currentStatus = STATUS.SETTING_UP
		$Label.text = "Setting Up Next Game"
	
		Settings.gameMode = Settings.GAME_MODE.TOURNAMENT
		
		if NodeLoc.getBoard() is get_script():
			print("Starting new tournament match")
			var root = get_node("/root")
			var main = load("res://Scenes/main.tscn").instance()
			Server.opponentID = opponentID
			root.add_child(main)
			get_tree().current_scene = main
			
			root.remove_child(self)
			self.queue_free()

func onQuitButtonPressed():
	var pop = popupUI.instance()
	pop.init("Quit Tournament", "Are you sure you want to quit? There will be no way to return", [["Yes", self, "toMainMenu", []], ["Back", pop, "close", []]])
	$CenterControl.add_child(pop)

func onSettingsPressed():
	$SettingsHolder/SettingsPage.visible = true

func toMainMenu():
	var error = get_tree().change_scene("res://Scenes/StartupScreen.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))

func editPlayerName(player_id, username):
	idToLabel[player_id].text = username

func editOwnName(username):
	editPlayerName(get_tree().get_network_unique_id(), username)
