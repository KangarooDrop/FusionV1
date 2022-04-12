extends Node

onready var parent = get_parent()
var timer = 0
var maxTime = 0
var fadingIn : bool
var fadingOut : bool

var freeOnFadeOut = true

signal onFadeIn
signal onFadeOut

func _ready():
	parent.modulate = Color(1, 1, 1, 0)
	
func _physics_process(delta):
	if fadingIn:
		if timer < maxTime:
			timer += delta
			if timer >= maxTime:
				parent.modulate = Color(1, 1, 1, 1)
				fadingIn = false
				emit_signal("onFadeIn")
	elif fadingOut:
		if timer > 0:
			timer -= delta
			if timer <= 0:
				parent.modulate = Color(1, 1, 1, 0)
				fadingOut = false
				emit_signal("onFadeOut")
				close()
	
	if fadingIn or fadingOut:
		parent.modulate = Color(1, 1, 1, timer / maxTime)
	
func setVisibility(a : float):
	parent.modulate = Color(1, 1, 1, a)
	timer = a * maxTime
	
func fadeIn():
	fadingIn = true
	
func fadeOut():
	fadingIn = false
	fadingOut = true

func close():
	if freeOnFadeOut:
		parent.queue_free()
	else:
		parent.modulate = Color(1, 1, 1, 0)
