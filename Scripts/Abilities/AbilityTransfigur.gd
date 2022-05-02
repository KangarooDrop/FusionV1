extends AbilityETB

class_name AbilityTransfigur

var bounceSlots := []
var statSet : int = 3

func _init(card : Card).("Transfigur", card, Color.blue, true, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onEffect", [clone(card), card.playerID, count - timesApplied])

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
		Server.slotClicked(Server.opponentID, slot.isOpponent, slot.currentZone, slot.get_index(), 1)
	
	if slot.currentZone == CardSlot.ZONES.CREATURE and is_instance_valid(slot.cardNode):
		slot.cardNode.select()
		if not bounceSlots.has(slot):
			SoundEffectManager.playSelectSound()
			bounceSlots.append(slot)
		else:
			SoundEffectManager.playUnselectSound()
			bounceSlots.erase(slot)
		if bounceSlots.size() >= count - timesApplied or bounceSlots.size() >= validTargets:
			
			for s in bounceSlots:
				s.cardNode.select()
				s.cardNode.card.power = statSet
				s.cardNode.card.toughness = statSet
				s.cardNode.card.maxToughness = statSet
				
			bounceSlots.clear()
			NodeLoc.getBoard().endGetSlot()
	
func genDescription(subCount = 0) -> String:
	var s = ""
	if count - subCount > 1:
		s = "When this creature is played, its controller chooses " + str(count - subCount) + " creatures and sets their power and toughness to " + str(statSet)
	else:
		s = "When this creature is played, its controller chooses a creature and set its power and toughness to " + str(statSet)
	return .genDescription() + s
