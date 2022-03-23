extends Node

var cardDists = 10
onready var cardWidth = ListOfCards.cardBackground.get_width()
var cardSlotScene = preload("res://Scenes/CardSlot.tscn")
var cardNodeScene = preload("res://Scenes/CardNode.tscn")

var numCards = 5
var cardSlotList := []
var cardNodeList := []

var returning = false
var grabbing = false
var cardGrabbing = null
var cardSpot = null
var grabTimer = 0
var grabMaxTime = 1

var cardSpeed = 600


func _ready():
	newCards()
	
func _physics_process(delta):
	if grabbing:
		grabTimer += delta
		if grabTimer >= grabMaxTime:
			var card = cardGrabbing.card
			grabbing = false
			cardGrabbing.queue_free()
			
			while cardSlotList.size() > 0:
				cardSlotList[0].queue_free()
				cardSlotList.remove(0)
			while cardNodeList.size() > 0:
				cardNodeList[0].queue_free()
				cardNodeList.remove(0)
			
		else:
			cardGrabbing.position.y += cardSpeed * delta / grabMaxTime
			for node in cardNodeList:
				node.position.y -= cardSpeed * 600 / grabMaxTime
				
	if returning:
		pass
	
func newCards():
	for i in range(numCards):
		var slot = cardSlotScene.instance()
		slot.isOpponent = false
		slot.currentZone = CardSlot.ZONES.NONE
		slot.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
		cardSlotList.append(slot)
		slot.get_node("SpotSprite").texture = null
		
		var cardNodeInst = cardNodeScene.instance()
		cardNodeInst.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
		slot.cardNode = cardNodeInst
		cardNodeInst.slot = slot
		cardNodeList.append(cardNodeInst)
		
		var card = ListOfCards.getCard(0)
		cardNodeInst.card = card
		cardNodeInst.visible = true
		
		add_child(slot)
		add_child(cardNodeInst)
		
	centerCards()

func returnCards():
	pass

func addCard(slot):
	grabbing = true
	cardGrabbing = slot.cardNode
	grabTimer = 0
	
	cardSlotList.erase(slot)
	cardNodeList.erase(slot.cardNode)
	
	slot.cardNode.slot = null
	slot.cardNode = null
	
	slot.queue_free()
	
func centerCards():
	BoardMP.centerNodes(cardSlotList, Vector2(), cardWidth, cardDists)
	BoardMP.centerNodes(cardNodeList, Vector2(), cardWidth, cardDists)

func onMouseDown(slot, button_index):
	if button_index == 1:
		if not grabbing:
			addCard(slot)
	
func onMouseUp(slot : CardSlot, button_index : int):
	pass
	
func onSlotEnter(slot):
	pass
	
func onSlotExit(slot):
	pass
