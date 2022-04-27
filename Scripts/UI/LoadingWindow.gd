extends Node

onready var lSprite = $Sprite

func _physics_process(delta):
	lSprite.rotation -= delta * PI
