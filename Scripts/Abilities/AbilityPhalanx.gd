extends Ability

class_name AbilityPhalanx

func _init(card : Card).("Phalanx", "Adjacent creatures get +1/+1", card, Color.darkgray, true):
	pass

func onEnter(board, slot):
	for s in card.cardNode.slot.getNeighbors():
		if is_instance_valid(s.cardNode):
			s.cardNode.card.power += count
			s.cardNode.card.toughness += count

func onOtherEnter(board, slot):
	for s in card.cardNode.slot.getNeighbors():
		if s == slot:
			s.cardNode.card.power += count
			s.cardNode.card.toughness += count

func onLeave(board):
	for s in card.cardNode.slot.getNeighbors():
		if is_instance_valid(s.cardNode):
			s.cardNode.card.power -= count
			s.cardNode.card.toughness -= count

func onOtherLeave(board, slot):
	if slot in card.cardNode.slot.getNeighbors():
		slot.cardNode.card.power -= count
		slot.cardNode.card.toughness -= count
	
func combine(abl : Ability):
	.combine(abl)
	desc = "Adjacent creatures get +" + str(count) + "/+" + str(count)
