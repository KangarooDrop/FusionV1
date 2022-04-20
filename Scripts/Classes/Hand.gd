extends CardDisplay

class_name HandNode

var fadingNode = preload("res://Scenes/UI/FadingNode.tscn")

var player

var deck

var drawTimer = 0
var drawMaxTime = 0.25
var drawQueue : Array

var discardMaxTime = 0.25
var discardQueue := []
var discardTimers := []
var discardPositions := []

export var handSize := 5
export var isOpponent = false
export var handVisible := true
var mulliganCount = 0

func _ready():
	maxVal = 1.1

func initHand(player):
	self.player = player
	isOpponent = player.isOpponent
	
	
func drawHand():
	var actualHandSize = handSize - mulliganCount + (0 if NodeLoc.getBoard().players[NodeLoc.getBoard().activePlayer] == player else 1)
	for i in range(actualHandSize):
		drawCard()

func reveal():
	for c in nodes:
		if not c.getCardVisible():
			c.flip()

func _physics_process(delta):
	if discardQueue.size() > 0:
		var toRemove = []
		for i in range(discardQueue.size()):
			discardQueue[i].cardNode.position = discardPositions[i] + lerp(Vector2(), Vector2(0, -100 * sign(discardQueue[i].global_position.y)), discardTimers[i] / discardMaxTime)
			discardTimers[i] += delta
			if discardTimers[i] >= discardMaxTime:
				toRemove.append(i)
		
		if toRemove.size() > 0:
			for i in range(toRemove.size()):
				var index = toRemove[i]
				
				nodes.erase(discardQueue[index].cardNode)
				slots.erase(discardQueue[index])
				
				NodeLoc.getBoard().addCardToGrave(player.UUID, discardQueue[index].cardNode.card)
				
				discardQueue[index].cardNode.queue_free()
				discardQueue[index].queue_free()
				
				discardQueue.remove(index)
				discardTimers.remove(index)
				discardPositions.remove(index)
				
				for j in range(i+1, toRemove.size()):
					toRemove[j] -= 1
			centerCards()
			
	elif drawQueue.size() > 0:
		if movingCards.size() == 0:
			SoundEffectManager.playDrawSound()
			
			var slotInst = cardSlotScene.instance()
			slotInst.currentZone = CardSlot.ZONES.HAND
			slotInst.isOpponent = isOpponent
			slotInst.playerID = player.UUID
			add_child(slotInst)
			slotInst.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
			slots.append(slotInst)
			
			var cardInst = cardNodeScene.instance()
			cardInst.card = drawQueue[0][0]
			drawQueue[0][0].cardNode = cardInst
			drawQueue[0][0].playerID = player.UUID
			cardInst.card.cardNode = cardInst
			cardInst.playerID = player.UUID
			cardInst.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
			add_child(cardInst)
			nodes.append(cardInst)
			
			slotInst.cardNode = cardInst
			slotInst.cardNode.slot = slotInst
			
			if drawQueue[0][1]:
				cardInst.global_position = slotInst.global_position
				cardInst.setCardVisible(handVisible or drawQueue[0][2])
				var fn = fadingNode.instance()
				fn.maxTime = 1
				fn.connect("onFadeIn", self, "cardFadeInFinish", [cardInst])
				cardInst.add_child(fn)
				fn.fadeIn()
			else:
				cardInst.setCardVisible(false)
				if handVisible or drawQueue[0][2]:
					cardInst.flip()
				cardInst.global_position = deck.global_position
				slotInst.global_position = deck.global_position
				
				for c in NodeLoc.getBoard().getAllCards():
					c.onDraw(cardInst.card)
			
			centerCards()
			if drawQueue[0][1]:
				if movingCards.size() > 0:
					cardInst.global_position = movingCards[movingCards.size()-1][1]
					slotInst.global_position = cardInst.global_position
			drawQueue.remove(0)

func cardFadeInFinish(cardNode):
	cardNode.get_node("FadingNode").queue_free()

func drawCard():
	var card = player.deck.pop()
	if player.deck.cards.size() <= 0 and is_instance_valid(deck.cardNode):
		deck.cardNode.queue_free()
		deck.cardNode = null
	if card != null:
		addCardToHand([card, false, false])
	else:
		player.takeDamage(player.drawDamage, null)
		player.drawDamage += 1
	#	addCardToHand([ListOfCards.getCard(0), true, true])

#[Card, drawFromDeck, takeDamage]
func discardIndex(index : int):
	if index >= 0 and index < slots.size():
		slots[index].disabled = true
		
		slots[index].cardNode.setCardVisible(true)
		discardQueue.append(slots[index])
		discardPositions.append(slots[index].position)
		discardTimers.append(0)

func addCardToHand(data : Array):
	if data[0] != null:
		data[0].ownerID = player.UUID
		if Settings.playAnimations:
			drawQueue.append(data)
		else:
			SoundEffectManager.playDrawSound()
			var slotInst = cardSlotScene.instance()
			slotInst.currentZone = CardSlot.ZONES.HAND
			slotInst.isOpponent = isOpponent
			slotInst.playerID = player.UUID
			add_child(slotInst)
			slots.append(slotInst)
			slotInst.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
			
			var cardInst = cardNodeScene.instance()
			cardInst.card = data[0]
			drawQueue[0][0].cardNode = cardInst
			data[0].playerID = player.UUID
			cardInst.card.cardNode = cardInst
			cardInst.setCardVisible(handVisible or data[0][2])
			cardInst.playerID = player.UUID
			add_child(cardInst)
			nodes.append(cardInst)
			cardInst.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
			
			slotInst.cardNode = cardInst
			slotInst.cardNode.slot = slotInst
			
			centerCards()
			
			for c in NodeLoc.getBoard().getAllCards():
				c.onDraw(cardInst.card)
