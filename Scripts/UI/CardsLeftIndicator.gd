extends Node2D

class_name CardsLeftIndicator

var indicatorImage = preload("res://Art/UI/CardsLeft.png")

enum CARD_DATA {CAN_USE, HELD, USED}
var cardSprites := []

func setCardData(numCanUse : int, numHeld : int, numUsed : int):
	var total = numCanUse + numHeld + numUsed
	var numOld = cardSprites.size()
	
	if total > numOld:
		for i in range(total - numOld):
			var sprite = Sprite.new()
			add_child(sprite)
			sprite.texture = indicatorImage
			sprite.region_enabled = true
			cardSprites.append(sprite)
	elif total < numOld:
		for i in range(numOld - total):
			cardSprites[0].queue_free()
			cardSprites.remove(0)
	
	var count = 0
	for i in range(numUsed):
		cardSprites[count].region_rect = Rect2(Vector2(48, 0), Vector2(24, 32))
		count += 1
	for i in range(numHeld):
		cardSprites[count].region_rect = Rect2(Vector2(24, 0), Vector2(24, 32))
		count += 1
	for i in range(numCanUse):
		cardSprites[count].region_rect = Rect2(Vector2(0, 0), Vector2(24, 32))
		count += 1
	
	BoardMP.centerNodes(cardSprites, Vector2(), 24, 6)
