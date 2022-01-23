extends Node

var hangMaxTime = 0.5
var hangTimer = 0
var hanging = false

func _ready():
	$FadingNode.connect("onFadeIn", self, "onFadeIn")
	$FadingNode.maxTime = 1
	$FadingNode.freeOnFadeOut = false

func _physics_process(delta):
	if hanging:
		hangTimer += delta
		if hangTimer > hangMaxTime:
			$FadingNode.fadeOut()
			hanging = false

func onFadeIn():
	hanging = true
	hangTimer = 0

func startTurn():
	hanging = false
	$FadingNode.fadeIn()
