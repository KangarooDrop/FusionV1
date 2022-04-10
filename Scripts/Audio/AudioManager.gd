extends Node2D

class_name AudioManager

var isDeafened = false
var volume = 0
var currentEffects := []

func deafen(toggle : bool = true):
	if toggle and isDeafened:
		isDeafened = false
		setVolume(volume)
	elif toggle or isDeafened:
		var tmp = volume
		setVolume(-100)
		volume = tmp
		isDeafened = true

func setVolume(value : float):
	volume = value
	if not isDeafened:
		for se in currentEffects:
			se.volume_db = value

func randomSoundEffect(choices : Array):
	return choices[randi() % choices.size()]

func createSoundEffect(soundEffect, pitch : float = 1, sigma : float = 0) -> AudioStreamPlayer:
	if soundEffect == null:
		print("NULL SOUND EFFECT:  ", soundEffect)
	var audioStream = AudioStreamPlayer.new()
	audioStream.connect("finished", self, "clearAudioStreamPlayer", [audioStream])
	audioStream.stream = soundEffect
	audioStream.volume_db = volume
	
	audioStream.pitch_scale = pitch + rand_range(-sigma, sigma)
		
	audioStream.play()
	add_child(audioStream)
	
	currentEffects.append(audioStream)
	
	return audioStream

func clearAudioStreamPlayer(player):
	player.queue_free()
	currentEffects.erase(player)

func clearAll():
	for ef in currentEffects:
		clearAudioStreamPlayer(ef)
