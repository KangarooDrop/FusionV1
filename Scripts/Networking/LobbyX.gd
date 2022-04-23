extends Node

var locked = false

var lockTexture = preload("res://Art/UI/lock.png")
var unlockTexture = preload("res://Art/UI/unlock.png")

func _ready():
	setLockTexture()

func setLockTexture():
	$PlayerLabel/TextureButton.texture_normal = lockTexture if locked else unlockTexture

func lockButtonPressed():
	locked = not locked
	setLockTexture()
