extends Ability

class_name AbilityPhalanx

func _init(card : Card).("Phalanx", "Adjacent creatures get +1/+1", card):
	pass

func onEnter(board, slot):
	for s in card.cardNode.slot.getNeighbors():
		if is_instance_valid(s.cardNode):
			s.cardNode.card.power += 1
			s.cardNode.card.toughness += 1

func onOtherEnter(board, slot):
	print(card.cardNode.slot.getNeighbors())
	for s in card.cardNode.slot.getNeighbors():
		if s == slot:
			s.cardNode.card.power += 1
			s.cardNode.card.toughness += 1

func onDeath(board):
	for s in card.cardNode.slot.getNeighbors():
		if is_instance_valid(s.cardNode):
			s.cardNode.card.power -= 1
			s.cardNode.card.toughness -= 1
