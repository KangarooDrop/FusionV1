extends Node2D

var cardSlotScene = preload("res://Scenes/CardSlot.tscn")
var cardNodeScene = preload("res://Scenes/CardNode.tscn")

var slots := []
var nodes := []

var totalWidth = 1000

func _ready():
	var num = 10
	for i in range(num):
		var cardSlot = cardSlotScene.instance()
		var cardNode = cardNodeScene.instance()
		
		cardNode.card = ListOfCards.getCard(0)
		
		cardSlot.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
		cardNode.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
		
		cardSlot.position = Vector2(-totalWidth / 2.0 + totalWidth * float(i) / num, 0)
		cardNode.position = cardSlot.position
		
		add_child(cardSlot)
		add_child(cardNode)
		
		slots.append(cardSlot)
		nodes.append(cardNode)
		
		cardSlot.get_node("SpotSprite").visible = false

func _physics_process(delta):
	var dist = float(totalWidth) / slots.size()
	var mousePos = get_global_mouse_position()
	
	#var dif = mousePos.x - slots[8].global_position.x
	
	#print(dRatio * dSign)
	
	for i in range(slots.size()):
		var dRatio = (mousePos - slots[i].global_position).length() / totalWidth
		slots[i].scale = Vector2(1, 1) * lerp(1, 1.5, pow(1 - dRatio, 5)) * Settings.cardSlotScale
		nodes[i].scale = Vector2(1, 1) * lerp(1, 1.5, pow(1 - dRatio, 5)) * Settings.cardSlotScale
