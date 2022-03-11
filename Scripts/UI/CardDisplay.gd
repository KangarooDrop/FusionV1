extends Control

var cardSlotScene = preload("res://Scenes/CardSlot.tscn")
var cardNodeScene = preload("res://Scenes/CardNode.tscn")
onready var cardWidth = ListOfCards.cardBackground.get_width()
onready var cardHeight = ListOfCards.cardBackground.get_height()

var slots := []
var nodes := []

var totalWidth = -1

var board

func _ready():
	myfunc()
	get_tree().get_root().connect("size_changed", self, "myfunc")

func myfunc():
	totalWidth = get_viewport_rect().size.x * 0.75
	if slots.size() > 0:
		centerCards()

func centerCards():
	var dist = max(min(totalWidth / slots.size(), cardWidth * 2), 0)#cardWidth#
	BoardMP.centerNodes(slots, Vector2(), 0, dist)
	BoardMP.centerNodes(nodes, Vector2(), 0, dist)

func addCard(card : Card):
	var cardSlot = cardSlotScene.instance()
	var cardNode = cardNodeScene.instance()
	
	cardSlot.board = board
	cardNode.card = card
	
	cardSlot.cardNode = cardNode
	cardNode.slot = cardSlot
	
	cardSlot.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
	cardNode.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
	
	add_child(cardSlot)
	add_child(cardNode)
	
	slots.append(cardSlot)
	nodes.append(cardNode)
	
	cardSlot.get_node("SpotSprite").visible = false
	
	centerCards()

func _physics_process(delta):
	if slots.size() > 0:
		var mousePos = get_global_mouse_position()
		
		var dists   := []
		var indexes := []
		
		for i in range(slots.size()):
			var dist = (mousePos - slots[i].global_position).length()
			var dRatio = dist / totalWidth
			var maxVal = Settings.cardSlotScale * 1.5
			var minVal = Settings.cardSlotScale
			var val = lerp(minVal, maxVal, pow(1 - dRatio, 5))
			#val = stepify(val, 0.05)
			
			slots[i].scale = Vector2(val, val)
			nodes[i].scale = Vector2(val, val)
			
			var placed = false
			for j in range(dists.size()):
				if dist > dists[j]:
					dists.insert(j, dist)
					indexes.insert(j, i)
					placed = true
					break
			if not placed:
				dists.append(dist)
				indexes.append(i)
		
		for i in range(indexes.size()):
			nodes[indexes[i]].z_index = i + 2
