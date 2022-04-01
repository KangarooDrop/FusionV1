extends Ability

class_name AbilityRekindle

var discardIndexes := []

func _init(card : Card).("Rekindle", card, Color.red, true, Vector2(0, 0)):
	pass

func onEnter(slot):
	.onEnter(slot)
	addToStack("onEffect", [clone(card), card.playerID, count])
	card.removeAbility(self)
	
func onEnterFromFusion(slot):
	.onEnterFromFusion(slot)
	addToStack("onEffect", [clone(card), card.playerID, count])
	card.removeAbility(self)

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
			discardIndexes.append(index)
			slot.cardNode.position.y -= 16
		else:
			discardIndexes.erase(index)
			slot.cardNode.position.y += 16
		
		if discardIndexes.size() >= hand.slots.size() or discardIndexes.size() >= count:
			for i in range(discardIndexes.size()):
				hand.discardIndex(discardIndexes[i])
			for i in range(count):
				hand.drawCard()
			NodeLoc.getBoard().endGetSlot()
	
func genDescription() -> String:
	return .genDescription() + "When this creature is played, choose " + str(count) + " cards to discard and then draw " + str(count) + " cards. Removes this ability"
