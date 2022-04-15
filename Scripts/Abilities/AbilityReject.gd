extends Ability

class_name AbilityReject

var discardIndexes := []

func _init(card : Card).("Reject", card, Color.purple, true, Vector2(0, 0)):
	pass

func onDeath():
	addToStack("onEffect", [clone(card)])

func slotClicked(slot : CardSlot):
	if slot == null:
		for p in NodeLoc.getBoard().players:
			if p.UUID == card.playerID:
				slot = p.hand.slots[randi() % p.hand.slots.size()]
				break
	
	if slot.currentZone == CardSlot.ZONES.HAND and slot.playerID == card.playerID:
		var hand : HandNode = slot.get_parent()
		var index = -1
		for i in range(hand.slots.size()):
			if hand.slots[i] == slot:
				index = i
		if not discardIndexes.has(index):
			SoundEffectManager.playSelectSound()
			discardIndexes.append(index)
			slot.cardNode.position.y -= 16
		else:
			SoundEffectManager.playUnselectSound()
			discardIndexes.erase(index)
			slot.cardNode.position.y += 16
		
		if discardIndexes.size() >= hand.slots.size() or discardIndexes.size() >= count:
			for i in range(discardIndexes.size()):
				hand.discardIndex(discardIndexes[i])
			NodeLoc.getBoard().endGetSlot()

static func onEffect(params):
	for p in NodeLoc.getBoard().players:
		if p.UUID == params[0].card.playerID:
			if p.hand.nodes.size() == 0:
				return
	NodeLoc.getBoard().getSlot(params[0], params[0].card.playerID) 

func genDescription(subCount = 0) -> String:
	var c = ""
	if count - subCount == 1:
		c = "When this creature dies, choose a card from your hand. Discard that card"
	else:
		c = "When this creature dies, choose " + str(count - subCount) + " cards" + " from your hand. Discard those cards"
	return .genDescription() + c
