extends Node

class_name TournamentLobby

func _ready():
	MusicManager.playLobbyMusic()
	checkNextGame()

func checkNextGame():
	print("Checking If Next Game Available")
	var id = get_tree().get_network_unique_id()
	if Tournament.tree.root.data == id:
		print("Woo hoo! A winner is you!")
	elif Tournament.tree.root.hasNoChildren():
		print("Too bad; so sad")
	else:
		var opponentID = Tournament.getOpponent(id)
		if opponentID > 0:
			Settings.gameMode = Settings.GAME_MODE.TOURNAMENT
			Settings.selectedDeck = ".draft.json"
			
			Server.requestGM(id, opponentID)
			
			while not Server.gmSet:
				yield(get_tree().create_timer(1), "timeout")
			
			if NodeLoc.getBoard() is get_script():
				print("Starting new tournament match")
				var root = get_node("/root")
				var main = load("res://Scenes/main.tscn").instance()
				Server.opponentID = opponentID
				root.add_child(main)
				get_tree().current_scene = main
				
				root.remove_child(self)
				self.queue_free()
