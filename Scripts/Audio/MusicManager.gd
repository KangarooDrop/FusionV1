extends AudioManager

var sampleBoards = \
[
	preload("res://Audio/Music/Nic-Silver-Reborn-in-a-Dream.mp3"),
	preload("res://Audio/Music/Canton_Floodwaters2-160.mp3"),
	preload("res://Audio/Music/Fluxx69_Head-Long-160.mp3"),
	preload("res://Audio/Music/LoopKitchen_ravenous130bpm-160.mp3"),
	preload("res://Audio/Music/TNH_The-Reason-Of-Techno-160.mp3")
]

enum TRACKS {NONE, BOARD, MAIN_MENU, DECK_EDITOR, LOBBY}
var currentTrack : int = TRACKS.NONE

func playMainMenuMusic():
	currentTrack = TRACKS.MAIN_MENU
	clearAll()
#	createSoundEffect(sampleBoard)

func playDeckEditorMusic():
	currentTrack = TRACKS.DECK_EDITOR
	clearAll()
#	createSoundEffect(sampleBoard)

func playBoardMusic():
	if currentTrack != TRACKS.BOARD:
		clearAll()
		createSoundEffect(randomSoundEffect(sampleBoards))
		currentTrack = TRACKS.BOARD
	else:
		pass

func playLobbyMusic():
	currentTrack = TRACKS.LOBBY
	clearAll()

func clearAudioStreamPlayer(player : AudioStreamPlayer):
	.clearAudioStreamPlayer(player)
	if currentTrack == TRACKS.BOARD:
		currentTrack = TRACKS.NONE
		playBoardMusic()
