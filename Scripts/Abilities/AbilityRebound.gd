extends Ability

class_name AbilityRebound

var bounceSlots := []

func _init(card : Card).("Rebound", card, Color.blue, true, Vector2(0, 0)):
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
	var validTargets = 0
	var board = NodeLoc.getBoard()
	for p in board.players:
		for s in board.creatures[p.UUID]:
			if is_instance_valid(s.cardNode):
				validTargets += 1
	if validTargets >= 1:
		board.getSlot(params[0], params[1])
	

func slotClicked(slot : CardSlot):
	var validTargets = 0
	var board = NodeLoc.getBoard()
	for p in board.players:
		for s in board.creatures[p.UUID]:
			if is_instance_valid(s.cardNode):
				validTargets += 1
	
	if slot == null:
		var creatureSlots = []
		for p in board.players:
			for s in board.creatures[p.UUID]:
				if is_instance_valid(s.cardNode):
					creatureSlots.append(s)
		slot = creatureSlots[randi() % creatureSlots.size()]
	
	if slot.currentZone == CardSlot.ZONES.CREATURE and is_instance_valid(slot.cardNode):
		if not bounceSlots.has(slot):
			bounceSlots.append(slot)
		if bounceSlots.size() >= count or bounceSlots.size() >= validTargets:
			
			for s in bounceSlots:
				for p in board.players:
					if p.UUID == s.playerID:
						p.hand.addCardToHand([s.cardNode.card.clone(), true, true])
						break
				
				s.cardNode.card.onLeave()
				for c in board.getAllCards():
					if c != s.cardNode.card:
						c.onOtherLeave(s.cardNode.slot)
				
				s.cardNode.slot.cardNode = null
				s.cardNode.queue_free()
				
			
			bounceSlots.clear()
			NodeLoc.getBoard().endGetSlot()
	
func genDescription() -> String:
	return .genDescription() + "When this creature is played, choose " + str(count) + " cards to discard and then draw " + str(count) + " cards. Removes this ability"
