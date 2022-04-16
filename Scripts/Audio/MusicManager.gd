extends AudioManager

var sampleBoards = \
[
	preload("res://Audio/Music/Nic-Silver-Reborn-in-a-Dream.mp3"),
	preload("res://Audio/Music/Canton_Floodwaters2-160.mp3"),
	preload("res://Audio/Music/Fluxx69_Head-Long-160.mp3"),
	preload("res://Audio/Music/LoopKitchen_ravenous130bpm-160.mp3"),
	preload("res://Audio/Music/TNH_The-Reason-Of-Techno-160.mp3"),
	preload("res://Audio/Music/Marco_Kalach-Synthetic_Fandango.mp3")
]

var sampleLobby = \
[
	preload("res://Audio/Music/marisameow_Soulful-Sunlight-160.mp3")
]

var sampleDeckEditor = \
[
	preload("res://Audio/Music/robbot-Z.mp3")
]

var sampleMenu = preload("res://Audio/Music/ScratchedAndMixed.mp3")

enum TRACKS {NONE, BOARD, MAIN_MENU, DECK_EDITOR, LOBBY}
var currentTrack : int = TRACKS.NONE

var fadeOutMaxTime = 1
var fadeOutRate = 60
var fadingTracks := {}

func playMainMenuMusic():
	if currentTrack != TRACKS.MAIN_MENU:
		currentTrack = TRACKS.NONE
		clearAll()
		createSoundEffect(sampleMenu)
		currentTrack = TRACKS.MAIN_MENU
	else:
		pass

func playDeckEditorMusic():
	if currentTrack != TRACKS.DECK_EDITOR:
		currentTrack = TRACKS.NONE
		clearAll()
		createSoundEffect(randomSoundEffect(sampleDeckEditor))
		currentTrack = TRACKS.DECK_EDITOR
	else:
		pass

func playBoardMusic():
	if currentTrack != TRACKS.BOARD:
		currentTrack = TRACKS.NONE
		clearAll()
		createSoundEffect(randomSoundEffect(sampleBoards))
		currentTrack = TRACKS.BOARD
	else:
		pass

func playLobbyMusic():
	if currentTrack != TRACKS.LOBBY:
		currentTrack = TRACKS.NONE
		clearAll()
		createSoundEffect(randomSoundEffect(sampleLobby))
		currentTrack = TRACKS.LOBBY
	else:
		pass

func clearAudioStreamPlayer(player : AudioStreamPlayer):
	fadeOut(player)
	
	
	if currentTrack == TRACKS.BOARD:
		currentTrack = TRACKS.NONE
		playBoardMusic()
	elif currentTrack == TRACKS.LOBBY:
		currentTrack = TRACKS.NONE
		playLobbyMusic()
	elif currentTrack == TRACKS.DECK_EDITOR:
		currentTrack = TRACKS.NONE
		playDeckEditorMusic()

func fadeOut(player : AudioStreamPlayer):
	fadingTracks[player] = fadeOutMaxTime

func _physics_process(delta):
	for ft in fadingTracks.keys():
		fadingTracks[ft] -= delta
		ft.volume_db -= fadeOutRate * delta
		if fadingTracks[ft] <= 0:
			.clearAudioStreamPlayer(ft)
			fadingTracks.erase(ft)
