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

export(int) var handSize := 5
export(bool) var handVisible := true
var mulliganCount = 0

var drawWaitTimer = 0
var drawWaitMaxTime = 0.15

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
		c.slot.shownToOpponent()

func _physics_process(delta):
	var dAnim = delta * Settings.animationSpeed
	
	if discardQueue.size() > 0:
		var toRemove = []
		for i in range(discardQueue.size()):
			discardQueue[i][0].cardNode.position = discardPositions[i] + lerp(Vector2(), Vector2(0, -100 * sign(discardQueue[i][0].global_position.y)), discardTimers[i] / discardMaxTime)
			discardTimers[i] += dAnim
			if discardTimers[i] >= discardMaxTime:
				toRemove.append(i)
		
		if toRemove.size() > 0:
			for i in range(toRemove.size()):
				var index = toRemove[i]
				
				nodes.erase(discardQueue[index][0].cardNode)
				slots.erase(discardQueue[index][0])
				
				if discardQueue[index][1]:
					NodeLoc.getBoard().addCardToGrave(player.UUID, discardQueue[index][0].cardNode.card)
				
				discardQueue[index][0].cardNode.queue_free()
				discardQueue[index][0].queue_free()
				
				discardQueue.remove(index)
				discardTimers.remove(index)
				discardPositions.remove(index)
				
				for j in range(i+1, toRemove.size()):
					toRemove[j] -= 1
			centerCards()
			
	elif drawQueue.size() > 0:
		if drawWaitTimer <= 0:
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
			
			if drawQueue[0][2]:
				slotInst.shownToOpponent()
			
			if drawQueue[0][1]:
				cardInst.global_position = slotInst.global_position
				cardInst.setCardVisible(handVisible or drawQueue[0][2])
				var fn = fadingNode.instance()
				fn.maxTime = 1
				fn.connect("onFadeIn", self, "cardFadeInFinish", [cardInst])
				cardInst.add_child(fn)
				fn.fadeIn()
				NodeLoc.getBoard().checkState()
			else:
				cardInst.setCardVisible(false)
				if handVisible or drawQueue[0][2]:
					cardInst.flip()
				cardInst.global_position = deck.global_position
				slotInst.global_position = deck.global_position
				
				for c in NodeLoc.getBoard().getAllCards():
					c.onDraw(cardInst.card)
				NodeLoc.getBoard().checkState()
			
			centerCards()
			if drawQueue[0][1]:
				if movingCards.size() > 0:
					cardInst.global_position = movingCards[movingCards.size()-1][1]
					slotInst.global_position = cardInst.global_position
			drawQueue.remove(0)
		
			drawWaitTimer = drawWaitMaxTime
			
	if drawWaitTimer > 0:
		drawWaitTimer -= dAnim

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
func discardIndex(index : int, addCardToGrave=true):
	if index >= 0 and index < slots.size():
		slots[index].disabled = true
		
		slots[index].cardNode.setCardVisible(true)
		discardQueue.append([slots[index], addCardToGrave])
		discardPositions.append(slots[index].position)
		discardTimers.append(0)

func addCardToHand(data : Array):
	if data[0] != null:
		data[0].ownerID = player.UUID
		drawQueue.append(data)
