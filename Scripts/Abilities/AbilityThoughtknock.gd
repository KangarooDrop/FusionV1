extends AbilityETB

class_name AbilityThoughtknock

var discardIndexes := []

func _init(card : Card).("Thoughtknock", card, Color.gold, true, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onEffect", [])

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
		
		if discardIndexes.size() >= hand.slots.size() or discardIndexes.size() >= myVars.count - myVars.timesApplied:
			for i in range(discardIndexes.size()):
				hand.discardIndex(discardIndexes[i])
			myVars.timesApplied = myVars.count
			discardIndexes.clear()
			NodeLoc.getBoard().endGetSlot()
			

func onEffect(params):
	var slectingUUID = -1
	for p in NodeLoc.getBoard().players:
		if p.UUID == card.playerID:
			if p.hand.nodes.size() == 0:
				return
			else:
				p.hand.reveal()
		else:
			slectingUUID = p.UUID
	NodeLoc.getBoard().getSlot(self, slectingUUID)

func genDescription(subCount = 0) -> String:
	var c = ""
	if myVars.count - subCount == 1:
		c = "When this creature is played, its controller reveals their hand and their opponent chooses a card from it. They discard that card"
	else:
		c = "When this creature is played, its controller reveals their hand and their opponent chooses " + str(myVars.count - subCount) + " cards" + " from it. They discard those cards"
	return .genDescription() + c
