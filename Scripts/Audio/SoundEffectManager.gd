extends AudioManager

var drawSounds = \
[
	preload("res://Audio/SoundEffects/CardPlaced/cardSlide1.ogg"), 
	preload("res://Audio/SoundEffects/CardPlaced/cardSlide4.ogg"),
	preload("res://Audio/SoundEffects/CardPlaced/cardSlide5.ogg"),
	preload("res://Audio/SoundEffects/CardPlaced/cardSlide6.ogg"),
]
var attackSound = preload("res://Audio/SoundEffects/CardAttack/dropLeather.ogg")
var selectSound = preload("res://Audio/SoundEffects/CardSelected/select_007.ogg")
var unselectSound = preload("res://Audio/SoundEffects/CardSelected/select_008.ogg")
var deathSound = preload("res://Audio/SoundEffects/CardDestroyed/zapsplat_foley_paper_rip_small_peices_single_002_11010.mp3")

func playAttackSound():
	createSoundEffect(attackSound, 1.5, 0.1)

func playDrawSound():
	createSoundEffect(randomSoundEffect(drawSounds), 1)

func playSelectSound():
	createSoundEffect(selectSound, 1)

func playUnselectSound():
	createSoundEffect(unselectSound, 1)

func playDeathSound():
	createSoundEffect(deathSound, 1)
