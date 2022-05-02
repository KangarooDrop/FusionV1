extends Ability

class_name AbilityAbandon

var discardIndexes := []

func _init(card : Card).("Abandon", card, Color.red, true, Vector2(0, 48)):
	pass

func onBeforeDamage(attacker, blocker):
	if attacker == card.cardNode.slot:
		addToStack("onEffect", [clone(card), card.playerID, count])

static func onEffect(params : Array):
	for p in NodeLoc.getBoard().players:
		if p.UUID == params[1]:
			if p.hand.slots.size() <= params[2]:
				for i in range(p.hand.nodes.size()):
					p.hand.discardIndex(i)
				return
	NodeLoc.getBoard().getSlot(params[0], params[1])

func slotClicked(slot : CardSlot):
	if slot == null:
		for p in NodeLoc.getBoard().players:
			if p.UUID == card.playerID:
				slot = p.hand.slots[randi() % p.hand.slots.size()]
				Server.slotClicked(Server.opponentID, slot.isOpponent, slot.currentZone, slot.get_index(), 1)
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

func genDescription(subCount = 0) -> String:
	return .genDescription() + ("When this creature attacks, its controller chooses and discards " + str(count) + " card") + ("s" if count > 1 else "")
