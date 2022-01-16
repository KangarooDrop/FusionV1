extends Node

var player = null

func _physics_process(delta):
	if player != null:
		$Label.text = "Life: " + str(player.life)
