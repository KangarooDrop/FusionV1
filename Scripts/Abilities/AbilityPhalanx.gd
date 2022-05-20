extends Ability

class_name AbilityPhalanx

func _init(card : Card).("Phalanx", card, Color.darkgray, true, Vector2(16, 48)):
	myVars["buffsApplied"] = 0

func onEnter(slot):
	for i in range(myVars.count - myVars.buffsApplied):
		onEffect()
		myVars.buffsApplied += 1

func onEnterFromFusion(slot):
	for i in range(myVars.count - myVars.buffsApplied):
		onEffect()
		myVars.buffsApplied += 1

func onOtherEnter(slot):
	if NodeLoc.getBoard().isOnBoard(card):
		for s in card.cardNode.slot.getNeighbors():
			if s == slot:
				s.cardNode.card.power += myVars.count
				s.cardNode.card.toughness += myVars.count
				s.cardNode.card.maxToughness += myVars.count

func onEffect():
	for s in card.cardNode.slot.getNeighbors():
		if is_instance_valid(s.cardNode):
			s.cardNode.card.power += 1
			s.cardNode.card.toughness += 1
			s.cardNode.card.maxToughness += 1

func onLeave():
	if is_instance_valid(card.cardNode):
		for s in card.cardNode.slot.getNeighbors():
			if is_instance_valid(s.cardNode):
				s.cardNode.card.power -= myVars.count
				s.cardNode.card.toughness -= myVars.count
				s.cardNode.card.maxToughness -= myVars.count

func onRemove(ability):
	if ability == self:
		if is_instance_valid(card.cardNode):
			for s in card.cardNode.slot.getNeighbors():
				if is_instance_valid(s.cardNode):
					s.cardNode.card.power -= myVars.count
					s.cardNode.card.toughness -= myVars.count
					s.cardNode.card.maxToughness -= myVars.count

func onOtherLeave(slot):
	if NodeLoc.getBoard().isOnBoard(card):
		if is_instance_valid(slot.cardNode):
			if slot in card.cardNode.slot.getNeighbors():
				slot.cardNode.card.power -= myVars.count
				slot.cardNode.card.toughness -= myVars.count
				slot.cardNode.card.maxToughness -= myVars.count
	
	
func clone(card : Card) -> Ability:
	var abl = .clone(card)
	abl.myVars.buffsApplied = myVars.buffsApplied
	return abl

func genDescription(subCount = 0) -> String:
	return .genDescription() + "Adjacent creatures get +" + str(myVars.count) + "/+" + str(myVars.count)
