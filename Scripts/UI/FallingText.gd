extends Node2D

var vel = Vector2()
var startingVelY = -300
var startingVelX = 100
var grav = 1000

var timer = 0
var maxTime = 2

func _ready():
	vel = Vector2(randf() * startingVelX * 2 - startingVelX, startingVelY)

func _physics_process(delta):
	vel.y += grav * delta
	position += vel * delta
	
	timer += delta
	if timer >= maxTime:
		queue_free()
	else:
		modulate = Color(1, 1, 1, 1 - timer / maxTime)
