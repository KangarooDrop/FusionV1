extends AbilityETB

class_name AbilityRebound

var bounceSlots := []

func _init(card : Card).("Rebound", card, Color.blue, true, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onEffect", [])

func onEffect(params : Array):
	var validTargets = 0
	var board = NodeLoc.getBoard()
	for p in board.players:
		for s in board.creatures[p.UUID]:
			if is_instance_valid(s.cardNode) and s.cardNode.card != card:
				validTargets += 1
	if validTargets >= 1:
		board.getSlot(self, card.playerID)
	else:
		myVars.timesApplied = myVars.count

func slotClicked(slot : CardSlot):
	var validTargets = 0
	var board = NodeLoc.getBoard()
	for p in board.players:
		for s in board.creatures[p.UUID]:
			if is_instance_valid(s.cardNode) and s.cardNode.card != self.card:
				validTargets += 1
	
	if slot == null:
		var creatureSlots = []
		for p in board.players:
			for s in board.creatures[p.UUID]:
				if is_instance_valid(s.cardNode):
					creatureSlots.append(s)
		slot = creatureSlots[randi() % creatureSlots.size()]
		Server.slotClicked(Server.opponentID, slot.isOpponent, slot.currentZone, slot.get_index(), 1)
	
	if slot.currentZone == CardSlot.ZONES.CREATURE and is_instance_valid(slot.cardNode) and slot.cardNode.card != self.card:
		slot.cardNode.select()
		if not bounceSlots.has(slot):
			SoundEffectManager.playSelectSound()
			bounceSlots.append(slot)
		else:
			SoundEffectManager.playUnselectSound()
			bounceSlots.erase(slot)
		if bounceSlots.size() >= myVars.count - myVars.timesApplied or bounceSlots.size() >= validTargets:
			
			for s in bounceSlots:
				s.cardNode.card.onLeave()
				for c in board.getAllCards():
					if c != s.cardNode.card:
						c.onOtherLeave(s.cardNode.slot)
				
				for p in board.players:
					if p.UUID == s.playerID:
						p.hand.addCardToHand([s.cardNode.card, false, true])
						s.cardNode.queue_free()
						break
				
			bounceSlots.clear()
			myVars.timesApplied = myVars.count
			NodeLoc.getBoard().endGetSlot()
	
func genDescription(subCount = 0) -> String:
	var s = ""
	if myVars.count - subCount > 1:
		s = "When this creature is played, choose " + str(myVars.count - subCount) + " other creatures and return them to their controllers' hands"
	else:
		s = "When this creature is played, choose another creature and return it to its controller's hand"
	return .genDescription() + s
