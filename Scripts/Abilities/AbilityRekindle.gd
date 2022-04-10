extends AbilityETB

class_name AbilityRekindle

var discardIndexes := []

func _init(card : Card).("Rekindle", card, Color.red, true, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onEffect", [clone(card), card.playerID, count - timesApplied])

static func onEffect(params : Array):
	for p in NodeLoc.getBoard().players:
		if p.UUID == params[1]:
			if p.hand.slots.size() <= params[2]:
				for i in range(p.hand.nodes.size()):
					p.hand.discardIndex(i)
				for i in range(params[2]):
					p.hand.drawCard()
				return
	NodeLoc.getBoard().getSlot(params[0], params[1])

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
			for i in range(count - timesApplied):
				hand.drawCard()
			NodeLoc.getBoard().endGetSlot()
	
func genDescription(subCount = 0) -> String:
	var string
	if count - subCount == 1:
		string = "1 card"
	else:
		string = str(count - subCount) + " cards"
	return .genDescription() + "When this creature is played, choose " + string + " to discard and then draw " + string
