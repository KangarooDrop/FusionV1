extends AbilityETB

class_name AbilityThoughtknock

var discardIndexes := []

func _init(card : Card).("Thoughtknock", card, Color.gold, true, Vector2(0, 0)):
	pass

func onApplied(slot):
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
		
		if discardIndexes.size() >= hand.slots.size() or discardIndexes.size() >= count - timesApplied:
			for i in range(discardIndexes.size()):
				hand.discardIndex(discardIndexes[i])
			NodeLoc.getBoard().endGetSlot()

static func onEffect(params):
	var slectingUUID = -1
	for p in NodeLoc.getBoard().players:
		if p.UUID == params[0].card.playerID:
			if p.hand.nodes.size() == 0:
				return
			else:
				p.hand.reveal()
		else:
			slectingUUID = p.UUID
	NodeLoc.getBoard().getSlot(params[0], slectingUUID)

func genDescription(subCount = 0) -> String:
	var c = ""
	if count - subCount == 1:
		c = "When this creature is played, reveal your hand and your opponent chooses a card from it. Discard that card"
	else:
		c = "When this creature is played, reveal your hand and your opponent chooses " + str(count - subCount) + " cards" + " from it. Discard those cards"
	return .genDescription() + c
