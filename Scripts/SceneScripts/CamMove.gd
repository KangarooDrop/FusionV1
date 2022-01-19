extends Camera2D

enum CAM_STATES {HAND, BOARD, OPPONENT, WIDE}

var currentState = CAM_STATES.BOARD

var moving = false
var moveTimer = 0
var moveMaxTime = 0.1
var movingToState = -1

var oldPos = null
var newPos = null
var oldScale = -1
var newScale = -1
var moveAmount = 175
var scaleAmount = 1.5

func _ready():
	moveCam(CAM_STATES.WIDE, Vector2(0, 0), zoom * scaleAmount)

func _physics_process(delta):
	if moving:
		moveTimer -= delta
		if moveTimer <= 0:
			position = newPos
			zoom = newScale
			moving = false
			currentState = movingToState
		else:
			var a = moveTimer / moveMaxTime
			position = lerp(newPos, oldPos, a)
			zoom = lerp(newScale, oldScale, a)
			
func _input(event):
	if event is InputEventKey and not event.is_echo() and event.is_pressed():
		if not moving:
			if event.scancode == KEY_W:
				if currentState == CAM_STATES.HAND or currentState == CAM_STATES.BOARD:
					moveCam(currentState + 1, position + Vector2(0, -moveAmount), zoom)
				elif currentState == CAM_STATES.WIDE:
					moveCam(CAM_STATES.OPPONENT, Vector2(0, -moveAmount), zoom / scaleAmount)
			elif event.scancode == KEY_S:
				if currentState == CAM_STATES.BOARD or currentState == CAM_STATES.OPPONENT:
					moveCam(currentState - 1, position + Vector2(0, moveAmount), zoom)
				elif currentState == CAM_STATES.WIDE:
					moveCam(CAM_STATES.HAND, Vector2(0, moveAmount), zoom / scaleAmount)
			elif event.scancode == KEY_SPACE:
				if currentState == CAM_STATES.WIDE:
					moveCam(CAM_STATES.BOARD, Vector2(0, 0), zoom / scaleAmount)
				else:
					moveCam(CAM_STATES.WIDE, Vector2(0, 0), zoom * scaleAmount)

func moveCam(stateWhenMoved : int, newPos : Vector2, newScale : Vector2):
	moving = true
	moveTimer = moveMaxTime
	movingToState = stateWhenMoved

	self.oldPos = position
	self.newPos = newPos
	self.oldScale = zoom
	self.newScale = newScale
