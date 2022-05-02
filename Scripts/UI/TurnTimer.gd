extends Node

class_name TurnTimer

var turnTimer = Settings.turnTimerMax
var gameTimer = Settings.gameTimerMax

var turnTimerRunning = false
var gameTimerRunning = false

var turnOver = false

var flipDelayTimer = 0
var flipDelayMaxTime = 2
var flippingTimer = 0
var flippingMaxTime = 0.5
var flipping = false

signal onTurnTimerEnd()
signal onGameTimerEnd()

func _ready():
	updateTurnTimer()
	updateGameTimer()

func startTurnTimer():
	turnTimerRunning = true
	$Sprite.visible = true
	
	if not gameTimerRunning:
		startGameTimer()

func stopTurnTimer():
	turnTimerRunning = false
	$Sprite.visible = false

	flipDelayTimer = 0
	flippingTimer = 0
	flipping = false
	$Sprite.rotation = 0
	
	if gameTimerRunning:
		stopGameTimer()

func resetTurnTimer():
	turnTimer = Settings.turnTimerMax
	updateTurnTimer()
	turnOver = false

func startGameTimer():
	gameTimerRunning = true

func stopGameTimer():
	gameTimerRunning = false
	gameTimer = ceil(gameTimer)

func resetGameTimer():
	gameTimer = Settings.gameTimerMax
	updateGameTimer()

func _physics_process(delta):
	if turnTimerRunning:
		if flipping:
			flippingTimer += delta
			if flippingTimer >= flippingMaxTime:
				flippingTimer = 0
				flipping = false
				$Sprite.scale.y *= -1
				$Sprite.rotation = 0
			else:
				$Sprite.rotation = lerp(0, PI, flippingTimer / flippingMaxTime)
		else:
			flipDelayTimer += delta
			if flipDelayTimer >= flipDelayMaxTime:
				flipDelayTimer = 0
				flipping = true
		
		if Settings.turnTimerMax != -1:
			turnTimer -= delta
			if turnTimer <= 0:
				stopTurnTimer()
				emit_signal("onTurnTimerEnd")
				turnOver = true
		updateTurnTimer()
			
	if gameTimerRunning:
		gameTimer -= delta
		if gameTimer <= 0:
			stopTurnTimer()
			emit_signal("onGameTimerEnd")
		updateGameTimer()
	

func updateTurnTimer():
	if Settings.turnTimerMax == -1:
		$Label.text = " --    "
	else:
		$Label.text = intToTime(max(int(turnTimer), 0))
	
func updateGameTimer():
	$Label2.text = intToTime(max(int(gameTimer), 0))

static func intToTime(num : int) -> String:
	var minutes = num / 60
	var seconds = int(num - minutes * 60)
	var minutesString = str(minutes)
	var secondsString = str(seconds)
	
#	if minutes > 0 and minutesString.length() == 1:
#		minutesString = "0" + minutesString
	if secondsString.length() == 1:
		secondsString = "0" + secondsString
	
	return minutesString + ":" + secondsString
