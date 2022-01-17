extends Node2D

var fadeTimer = 0
var fadeMaxTime = 1
var fadingIn = true
var fadingOut = false
var finalAlpha = 0.4

func _physics_process(delta):
	if fadingIn:
		fadeTimer += delta
		if fadeTimer >= fadeMaxTime:
			fadingIn = false
			fadeTimer = fadeMaxTime
	if fadingOut:
		fadeTimer -= delta
		if fadeTimer <= 0:
			queue_free()
			
	if fadingIn or fadingOut:
		modulate = Color(1, 1, 1, lerp(0, finalAlpha, fadeTimer / fadeMaxTime))

func fadeOut():
	fadingIn = false
	fadingOut = true
