extends Control

enum PANNING_DIR {NONE, UP, DOWN}

var totalDelta = -1
var panning = PANNING_DIR.NONE
var speed = 20

var waitTimer = 0
var waitMaxTime = 3

var distPerTick = 10

func show():
	.show()
	var totalHeight = rect_size.y
	var screenSize = get_viewport().get_visible_rect().size
	totalDelta = totalHeight - screenSize.y
	#if totalDelta > 0:
	#	panning = PANNING_DIR.UP
	waitTimer = 0

func _physics_process(delta):
	if waitTimer < waitMaxTime:
		waitTimer += delta
	else:
		if panning == PANNING_DIR.UP:
			rect_position.y -= delta * speed
			if rect_position.y <= -totalDelta:
				panning = PANNING_DIR.DOWN
				waitTimer = 0
		elif panning == PANNING_DIR.DOWN:
			rect_position.y += delta * speed
			if rect_position.y >= 0:
				panning = PANNING_DIR.UP
				waitTimer = 0

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_DOWN:
			shift(-distPerTick)
		if event.button_index == BUTTON_WHEEL_UP:
			shift(distPerTick)
	elif event is InputEventKey:
		if event.is_pressed() and not event.is_echo():
			if event.scancode == KEY_DOWN:
				shift(-distPerTick)
			elif event.scancode == KEY_UP:
				shift(distPerTick)

func shift(dist):
	rect_position.y = min(max(rect_position.y + dist, -totalDelta), 0)

func _on_CreditsLabel_meta_clicked(meta):
	OS.shell_open(meta)
