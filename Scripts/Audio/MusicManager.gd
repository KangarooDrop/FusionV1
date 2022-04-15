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

enum TRACKS {NONE, BOARD, MAIN_MENU, DECK_EDITOR, LOBBY}
var currentTrack : int = TRACKS.NONE

func playMainMenuMusic():
	currentTrack = TRACKS.MAIN_MENU
	clearAll()
#	createSoundEffect(sampleBoard)

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
	.clearAudioStreamPlayer(player)
	
	if currentTrack == TRACKS.BOARD:
		currentTrack = TRACKS.NONE
		playBoardMusic()
	elif currentTrack == TRACKS.LOBBY:
		currentTrack = TRACKS.NONE
		playLobbyMusic()
	elif currentTrack == TRACKS.DECK_EDITOR:
		currentTrack = TRACKS.NONE
		playDeckEditorMusic()
