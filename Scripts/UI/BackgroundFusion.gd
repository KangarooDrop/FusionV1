extends Node

onready var cardWidth = ListOfCards.cardBackground.get_width()
var cardNode = preload("res://Scenes/CardNode.tscn")

var cardMoveSpeed = 200
var fuseSpinMaxTime = 0.75
var fuseRPS = 2
var fuseSpinWaitMaxTime = 0.5

#[card1, card2, point, rot, scale.x, fuseSpinWaitTimer, fuseSpinTimer, ]
var backFuseData := []
var backFuseBuffer = 0.1

#[card]
var backMovingData := []

#[card, time]
var backFadeData := []
var backFadeMaxTime = 3

var backFuseSpawnTimer = 0
var backFuseSpawnMaxTime = 2

var maxLayer = 100

var playing = false
var paused = false

func _ready():
	seed(OS.get_system_time_msecs())

func start():
	if not playing:
		clear()
		playing = true
		for i in range(100):
			_physics_process(1.0 / 60)
	if paused:
		pause()

func pause():
	for data in backFuseData:
		data[0].visible = paused
		data[1].visible = paused
	
	for data in backFadeData:
		data[0].visible = paused
	
	for data in backMovingData:
		data[0].visible = paused
	
	paused = not paused

func stop():
	playing = false
	paused = false
	clear()

func clear():
	for data in backFuseData:
		data[0].queue_free()
		data[1].queue_free()
	backFuseData.clear()
	
	for data in backFadeData:
		data[0].queue_free()
	backFadeData.clear()
	
	for data in backMovingData:
		data[0].queue_free()
	backMovingData.clear()
	
	backFuseSpawnTimer = 0

func _physics_process(delta):
	var dAnim = delta * Settings.animationSpeed
	
	if playing and not paused:
		backFuseSpawnTimer += delta
		if backFuseSpawnTimer >= backFuseSpawnMaxTime:
			backFuseSpawnTimer -= backFuseSpawnMaxTime
			if randi() % 3 == 0:
				genBackgroundMoving()
			else:
				genBackgroundFusion()
		
		for data in backFuseData:
			
			if data[5] == 0 and (data[0].position - data[1].position).length() > cardMoveSpeed * data[4] * delta:
				data[0].position += Vector2(-cardMoveSpeed * data[4], 0).rotated(data[3]) * delta
				data[1].position += Vector2(cardMoveSpeed * data[4], 0).rotated(data[3]) * delta
				
				if (data[0].position - data[1].position).length() <= cardMoveSpeed * data[4] * delta:
					data[0].flipToSameSide()
					data[1].flipToSameSide()
			
			elif data[5] < fuseSpinWaitMaxTime:
				data[5] += delta
				data[0].position = data[2] + Vector2(lerp(0, cardWidth * 1.5 * data[4], data[5] / fuseSpinWaitMaxTime), 0).rotated(data[3])
				data[1].position = data[2] + Vector2(lerp(0, -cardWidth * 1.5 * data[4], data[5] / fuseSpinWaitMaxTime), 0).rotated(data[3])
				
			elif data[6] < fuseSpinMaxTime:
				data[6] += delta
						
				var x = data[6] / fuseSpinMaxTime
				var ss
				if x < 0.5:
					ss = 0.5 - sqrt(.25 - x*x)
				else:
					ss = 0.5 + sqrt(.25 - (x-1)*(x-1))
	
				data[0].position = data[2] + Vector2(lerp(cardWidth * 1.5 * data[4], 0, data[6] / fuseSpinMaxTime), 0).rotated(data[6] / fuseSpinMaxTime * PI * 2 * fuseRPS + data[3])
				data[1].position = data[2] + Vector2(lerp(-cardWidth * 1.5 * data[4], 0, data[6] / fuseSpinMaxTime), 0).rotated(data[6] / fuseSpinMaxTime * PI * 2 * fuseRPS + data[3])
				
				if data[6] >= fuseSpinMaxTime:
					data[0].card.fuseToSelf(data[1].card)
					var cn = genBackgroundCard(data[0].card, data[3])
					cn.z_index = data[0].z_index
					cn.scale = data[0].scale
					cn.position = (data[0].position + data[1].position) / 2
					backFadeData.append([cn, 0])
					data[0].queue_free()
					data[1].queue_free()
					backFuseData.erase(data)
		
		for data in backFadeData:
			data[0].modulate.a = (backFadeMaxTime - data[1]) / backFadeMaxTime
			data[1] += delta
			if data[1] >= backFadeMaxTime:
				data[0].queue_free()
				backFadeData.erase(data)
		
		for data in backMovingData:
			data[0].position += Vector2(-cardMoveSpeed * data[0].scale.x, 0).rotated(data[0].rotation) * delta
			if data[0].position.length() > data[1]:
				data[0].queue_free()
				backMovingData.erase(data)

func genBackgroundMoving():
	var screenSize = get_viewport().get_visible_rect().size
	var card = ListOfCards.generateCard()
		
	var fusePoint = Vector2(randi() % int(screenSize.x * (1-backFuseBuffer)) + int(screenSize.x * backFuseBuffer/2), randi() % int(screenSize.y * (1-backFuseBuffer)) + int(screenSize.y * backFuseBuffer/2))
	var angle = 2 * PI * randf()
	var maxLen = max(screenSize.x, screenSize.y)
	var startPos1 = fusePoint + Vector2(maxLen, 0).rotated(angle)
	var layer = randi() % maxLayer
	var scale = lerp(Settings.cardSlotScale / 2.0, Settings.cardSlotScale * 1.5, float(layer) / maxLayer)
	
	var cn = genBackgroundCard(card, angle)
	cn.position = startPos1
	cn.z_index = -100 - maxLayer + layer
	cn.scale = Vector2(scale, scale)
	
	backMovingData.append([cn, maxLen * 2])
	

func genBackgroundFusion():
	var screenSize = get_viewport().get_visible_rect().size
	var ready = false
	var c1
	var c2
	while not ready:
		c1 = ListOfCards.generateCard()
		c2 = ListOfCards.generateCard()
		ready = ListOfCards.canFuseCards([c1, c2])
		
	var fusePoint = Vector2(randi() % int(screenSize.x * (1-backFuseBuffer)) + int(screenSize.x * backFuseBuffer/2), randi() % int(screenSize.y * (1-backFuseBuffer)) + int(screenSize.y * backFuseBuffer/2))
	var angle = 2 * PI * randf()
	if angle > PI/2 and angle < 3 * PI / 2:
		angle += PI
	var maxLen = max(screenSize.x, screenSize.y)
	var startPos1 = fusePoint + Vector2(maxLen, 0).rotated(angle)
	var startPos2 = fusePoint + Vector2(maxLen, 0).rotated(angle + PI)
	var layer = randi() % maxLayer
	#print(float(layer) / maxLayer)
	var scale = lerp(Settings.cardSlotScale / 2.0, Settings.cardSlotScale * 1.5, float(layer) / maxLayer)
	
	var cn1 = genBackgroundCard(c1, angle)
	cn1.position = startPos1
	cn1.z_index = -100 - maxLayer + layer
	cn1.scale = Vector2(scale, scale)
	var cn2 = genBackgroundCard(c2, angle)
	cn2.position = startPos2
	cn2.z_index = -100 - maxLayer + layer
	cn2.scale = Vector2(scale, scale)
	
	backFuseData.append([cn1, cn2, fusePoint, cn1.rotation, cn1.scale.x, 0, 0])

func genBackgroundCard(card : Card, angle : float) -> CardNode:
	var cn = cardNode.instance()
	cn.card = card
	cn.setCardVisible(true)
	add_child(cn)
	move_child(cn, 0)
	cn.rotation = angle
	return cn
