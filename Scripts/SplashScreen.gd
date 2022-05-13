extends Node

var angleOff = -PI * 0.03

var fadingNode = preload("res://Scenes/UI/FadingNode.tscn")
var titleSprite = preload("res://Art/UI/title.png")

onready var lSprite
onready var rSprite

var waitTimer = 0
var waitMaxTime = 1

var moveTimer = 0
var moveMaxTime = 0.5

var spinTimer = 0
var spinMaxTime = 1.5

var rps = PI * 2 * 4

var contShowing = false
var contTimer = 0

var screenSize
var bounds 

func _ready():
	bounds = Vector2(titleSprite.get_width(), titleSprite.get_height())
	screenSize = get_viewport().get_visible_rect().size
	
	lSprite = Sprite.new()
	lSprite.texture = titleSprite
	lSprite.region_enabled = true
	lSprite.region_rect = Rect2(Vector2(0, 0), Vector2(bounds.x/2, bounds.y))
	lSprite.name = "LeftSprite"
	$FuseCenter.add_child(lSprite)
	lSprite.visible = false
	
	rSprite = Sprite.new()
	rSprite.texture = titleSprite
	rSprite.region_enabled = true
	rSprite.region_rect = Rect2(Vector2(bounds.x/2, 0), Vector2(bounds.x/2, bounds.y))
	rSprite.name = "RightSprite"
	$FuseCenter.add_child(rSprite)
	rSprite.visible = false

func _physics_process(delta):
	if waitTimer < waitMaxTime:
		waitTimer += delta
		if waitTimer >= waitMaxTime:
			lSprite.visible = true
			rSprite.visible = true
			lSprite.rotation = angleOff
			rSprite.rotation = angleOff
			lSprite.position = Vector2(-screenSize.x / 2 * 1.5, 0).rotated(angleOff)
			rSprite.position = Vector2(screenSize.x / 2 * 1.5, 0).rotated(angleOff)
	elif moveTimer < moveMaxTime:
		moveTimer += delta
		var x = moveTimer / moveMaxTime
		var ss = x*x
		lSprite.position = Vector2(lerp(-screenSize.x / 2 * 1.5, 0, ss), 0).rotated(angleOff)
		rSprite.position = Vector2(lerp( screenSize.x / 2 * 1.5, 0, ss), 0).rotated(angleOff)
	elif spinTimer < spinMaxTime:
		spinTimer += delta
		var x = spinTimer / spinMaxTime
		var ss = pow(spinTimer / spinMaxTime, 0.5)
		if x < 0.5:
			ss = 0.5 - sqrt(.25 - x*x)
		else:
			ss = 0.5 + sqrt(.25 - (x-1)*(x-1))
		lSprite.position = Vector2(-bounds.x / 4, 0).rotated(rps * ss + angleOff)
		rSprite.position = Vector2( bounds.x / 4, 0).rotated(rps * ss + angleOff)
	elif not $ContLabel.visible:
		showLabel()
	elif contShowing:
		contTimer += delta
		$ContLabel.modulate = Color(1, 1, 1, cos(contTimer) * 0.5 + 0.5)

func showLabel():
	$ContLabel.visible = true
	var fn = fadingNode.instance()
	fn.name = "FadingNode"
	fn.maxTime = 1
	fn.connect("onFadeIn", self, "onFadeIn")
	$ContLabel.add_child(fn)
	fn.fadeIn()

func onFadeIn():
	contShowing = true

func _input(event):
	if event.is_pressed():
		if not contShowing:
			showLabel()
			$ContLabel/FadingNode.timer = $ContLabel/FadingNode.maxTime - 0.001
			lSprite.visible = true
			rSprite.visible = true
			lSprite.position = Vector2(-bounds.x / 4, 0).rotated(angleOff)
			rSprite.position = Vector2( bounds.x / 4, 0).rotated(angleOff)
			lSprite.rotation = angleOff
			rSprite.rotation = angleOff
			waitTimer = waitMaxTime
			moveTimer = moveMaxTime
			spinTimer = spinMaxTime
		else:
			var error = get_tree().change_scene("res://Scenes/Login/Home.tscn")
			if error != 0:
				print("Error loading test1.tscn. Error Code = " + str(error))
