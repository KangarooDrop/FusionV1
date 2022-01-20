extends Ability

class_name AbilityComposite

var buff = 1

func _init(card : Card).("Composite", "Gains +1/+0 for each other creature you control", card):
	pass

func onEnter(board, slot):
	for s in board.creatures[card.cardNode.slot.playerID]:
		if is_instance_valid(s.cardNode) and s != slot:
			card.power += buff

func onOtherEnter(board, slot):
	card.power += buff
	
func onLeave(board):
	for s in board.creatures[card.cardNode.slot.playerID]:
		if is_instance_valid(s.cardNode) and s != card.cardNode.slot:
			card.power -= buff
	
func onOtherLeave(board, slot):
	card.power -= buff
	
func combine(abl : Ability):
	.combine(abl)
	buff += abl.buff
	desc = "Gains +" + str(buff) + "/+0 for each other creature you control"

func _to_string():
	return name + " x" + str(buff) +" - " + desc

func clone(card : Card) -> Ability:
	var abl = get_script().new(card)
	abl.buff = buff
	return abl
