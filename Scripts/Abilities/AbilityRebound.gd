extends AbilityETB

class_name AbilityRebound

var bounceSlots := []

func _init(card : Card).("Rebound", card, Color.blue, true, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onEffect", [clone(card), card.playerID, count - timesApplied])

static func onEffect(params : Array):
	var validTargets = 0
	var board = NodeLoc.getBoard()
	for p in board.players:
		for s in board.creatures[p.UUID]:
			if is_instance_valid(s.cardNode) and s.cardNode.card != params[0].card:
				validTargets += 1
	if validTargets >= 1:
		board.getSlot(params[0], params[1])

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
	
	if slot.currentZone == CardSlot.ZONES.CREATURE and is_instance_valid(slot.cardNode) and slot.cardNode.card != self.card:
		if not bounceSlots.has(slot):
			SoundEffectManager.playSelectSound()
			bounceSlots.append(slot)
		else:
			SoundEffectManager.playUnselectSound()
			bounceSlots.erase(slot)
		if bounceSlots.size() >= count - timesApplied or bounceSlots.size() >= validTargets:
			
			for s in bounceSlots:
				s.cardNode.card.onLeave()
				for c in board.getAllCards():
					if c != s.cardNode.card:
						c.onOtherLeave(s.cardNode.slot)
				
				for p in board.players:
					if p.UUID == s.playerID:
						p.hand.addCardToHand([s.cardNode.card.clone(), true, true])
						break
				
				s.cardNode.slot.cardNode = null
				s.cardNode.queue_free()
				
			bounceSlots.clear()
			NodeLoc.getBoard().endGetSlot()
	
func genDescription(subCount = 0) -> String:
	var s = ""
	if count - subCount > 1:
		s = "When this creature is played, choose " + str(count - subCount) + " other creatures and return them to their owners' hands"
	else:
		s = "When this creature is played, choose another creature and return it to its owner's hand"
	return .genDescription() + s
