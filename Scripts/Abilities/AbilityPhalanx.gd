extends Ability

class_name AbilityPhalanx

var buff = 1

func _init(card : Card).("Phalanx", "Adjacent creatures get +1/+1", card):
	pass

func onEnter(board, slot):
	for s in card.cardNode.slot.getNeighbors():
		if is_instance_valid(s.cardNode):
			s.cardNode.card.power += buff
			s.cardNode.card.toughness += buff

func onOtherEnter(board, slot):
	for s in card.cardNode.slot.getNeighbors():
		if s == slot:
			s.cardNode.card.power += buff
			s.cardNode.card.toughness += buff

func onLeave(board):
	for s in card.cardNode.slot.getNeighbors():
		if is_instance_valid(s.cardNode):
			s.cardNode.card.power -= buff
			s.cardNode.card.toughness -= buff

func onOtherLeave(board, slot):
	if slot in card.cardNode.slot.getNeighbors():
		slot.cardNode.card.power -= buff
		slot.cardNode.card.toughness -= buff
	
func combine(abl : Ability):
	.combine(abl)
	buff += abl.buff
	desc = "Adjacent creatures get +" + str(buff) + "/+" + str(buff)
	
func _to_string():
	return name + " x" + str(buff) +" - " + desc

func clone(card : Card) -> Ability:
	var abl = get_script().new(card)
	abl.buff = buff
	return abl
