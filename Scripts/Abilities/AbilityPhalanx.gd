extends Ability

class_name AbilityPhalanx

var buffsApplied = 0

func _init(card : Card).("Phalanx", card, Color.darkgray, true, Vector2(16, 48)):
	pass

func onEnter(slot):
	for i in range(count - buffsApplied):
		onEffect()
		buffsApplied += 1

func onEnterFromFusion(slot):
	for i in range(count - buffsApplied):
		onEffect()
		buffsApplied += 1

func onOtherEnter(slot):
	if NodeLoc.getBoard().isOnBoard(card):
		for s in card.cardNode.slot.getNeighbors():
			if s == slot:
				s.cardNode.card.power += count
				s.cardNode.card.toughness += count
				s.cardNode.card.maxToughness += count

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
				s.cardNode.card.power -= count
				s.cardNode.card.toughness -= count
				s.cardNode.card.maxToughness -= count

func onRemove(ability):
	if ability == self:
		if is_instance_valid(card.cardNode):
			for s in card.cardNode.slot.getNeighbors():
				if is_instance_valid(s.cardNode):
					s.cardNode.card.power -= count
					s.cardNode.card.toughness -= count
					s.cardNode.card.maxToughness -= count

func onOtherLeave(slot):
	if NodeLoc.getBoard().isOnBoard(card):
		if is_instance_valid(slot.cardNode):
			if slot in card.cardNode.slot.getNeighbors():
				slot.cardNode.card.power -= count
				slot.cardNode.card.toughness -= count
				slot.cardNode.card.maxToughness -= count
	
	
func clone(card : Card) -> Ability:
	var abl = .clone(card)
	abl.buffsApplied = buffsApplied
	return abl

func combine(abl : Ability):
	.combine(abl)
	abl.buffsApplied += buffsApplied

func genDescription(subCount = 0) -> String:
	return .genDescription() + "Adjacent creatures get +" + str(count) + "/+" + str(count)
