extends Ability

class_name AbilityReject

var discardIndexes := []

func _init(card : Card).("Reject", card, Color.purple, true, Vector2(0, 0)):
	pass

func onDeath():
	addToStack("onEffect", [])

func onEffect(params):
	for p in NodeLoc.getBoard().players:
		if p.UUID == card.playerID:
			if p.hand.nodes.size() == 0:
				return
	NodeLoc.getBoard().getSlot(self, card.playerID) 

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
		
		if discardIndexes.size() >= hand.slots.size() or discardIndexes.size() >= myVars.count:
			for i in range(discardIndexes.size()):
				hand.discardIndex(discardIndexes[i])
			discardIndexes.clear()
			NodeLoc.getBoard().endGetSlot()

func genDescription(subCount = 0) -> String:
	var c = ""
	if myVars.count - subCount == 1:
		c = "When this creature dies, its controller chooses a card from their hand and discards it"
	else:
		c = "When this creature dies, its controller chooses " + str(myVars.count - subCount) + " cards their your hand and discard them"
	return .genDescription() + c
