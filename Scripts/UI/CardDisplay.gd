extends Node2D

var cardSlotScene = preload("res://Scenes/CardSlot.tscn")
var cardNodeScene = preload("res://Scenes/CardNode.tscn")

var slots := []
var nodes := []

var totalWidth = 1000
var force = 0.001

func _ready():
	var num = 10
	for i in range(num):
		var cardSlot = cardSlotScene.instance()
		var cardNode = cardNodeScene.instance()
		
		cardNode.card = ListOfCards.getCard(0)
		
		cardSlot.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
		cardNode.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
		
		cardSlot.position = Vector2(-totalWidth / 2.0 + totalWidth * float(i) / num, 0)
		
		add_child(cardSlot)
		add_child(cardNode)
		
		slots.append(cardSlot)
		nodes.append(cardNode)

func _physics_process(delta):
	var dist = float(totalWidth) / slots.size()
	var mousePos = get_global_mouse_position()
	#print(mousePos.x - slots[9].global_position.x)
	#print(dist)
	
	for i in range(slots.size()):
		for j in range(slots.size()):
			if i != j and i == 0:
				var length = abs(i-j) * dist
				var d = slots[i].position.x - slots[j].position.x
				slots[j].position.x += (d - length) * force
			"""
		if i > 0:
			var d = slots[i].position.x - slots[i-1].position.x
			slots[i-1].position.x += (d - dist) * force
		if i < slots.size() - 1:
			var d = slots[i+1].position.x - slots[i].position.x
			slots[i+1].position.x += (dist - d) * force
			
		slots[i].position.x += (mousePos.x - slots[i].global_position.x) * force
	"""
	slots[0].position.x = -totalWidth / 2
	slots[slots.size() - 1].position.x = totalWidth / 2
	for i in range(slots.size()):
		nodes[i].position = slots[i].position
	
	
	"""
	
	#print(get_viewport().get_visible_rect().size.x)
	#print(get_viewport().get_mouse_position().x)
	var totalWidth = 500
	var offset = float(get_viewport().get_mouse_position().x - totalWidth / 2) / totalWidth
	var totalDist = 0
	var totalNum = slots.size()
	for i in range(totalNum):
		totalDist += getFuncVal(i, totalNum, max(0, min(1, offset)))
		
	var mul = totalWidth / totalDist
	#var test = 0
	for i in range(totalNum):
		if i == 0:
			print(getFuncVal(i, totalNum, max(-1, min(1.25, offset))))
			slots[i].position.x = -totalWidth/2.0 + mul * getFuncVal(i, totalNum, max(-1, min(1.25, offset)))
		else:
			slots[i].position.x = slots[i - 1].position.x + mul * getFuncVal(i, totalNum, max(-1, min(1.25, offset)))
		
		nodes[i].position = slots[i].position
	"""

static func getFuncVal(index : int, maxIndex : int, off : float) -> float:
	var x = float(index) / maxIndex
	if x == 0 and off < 0:
		return 0.0
	if off >= 1:
		return x / off
	elif off <= 0:
		return -(x-1)/(1-off)
	elif x > off:
		return -(x-1)/(1-off)
		#s/((x-off)+s)
	else:
		if off == 0:
			return 0.0
		return x/off
		#s/((-x+off)+s)
