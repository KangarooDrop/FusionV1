extends AbilityETB

class_name AbilityRekindle

var discardIndexes := []

func _init(card : Card).("Rekindle", card, Color.red, true, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onEffect", [])

func onEffect(params : Array):
	for p in NodeLoc.getBoard().players:
		if p.UUID == card.playerID:
			if p.hand.slots.size() <= myVars.count - myVars.timesApplied:
				for i in range(p.hand.nodes.size()):
					p.hand.discardIndex(i)
				for i in range(myVars.count - myVars.timesApplied):
					p.hand.drawCard()
				
				myVars.timesApplied = myVars.count
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
		
		if discardIndexes.size() >= hand.slots.size() or discardIndexes.size() >= myVars.count - myVars.timesApplied:
			for i in range(discardIndexes.size()):
				hand.discardIndex(discardIndexes[i])
			for i in range(myVars.count - myVars.timesApplied):
				hand.drawCard()
			myVars.timesApplied = myVars.count
			discardIndexes.clear()
			NodeLoc.getBoard().endGetSlot()
	
func genDescription(subCount = 0) -> String:
	var string
	if myVars.count - subCount == 1:
		string = "1 card"
	else:
		string = str(myVars.count - subCount) + " cards"
	return .genDescription() + "When this creature is played, its controller chooses " + string + " cards to discard and then draws " + string
