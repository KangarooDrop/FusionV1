extends Ability

class_name AbilitySacrifice

var buff = 1

func _init(card : Card).("Sacrifice", "This creature gives your other creatures on board +1/+1 when it dies", card):
	pass

func onDeath(board):
	.onDeath(board)
	for slot in board.creatures[card.playerID]:
		if is_instance_valid(slot.cardNode):
			slot.cardNode.card.power += buff
			slot.cardNode.card.toughness += buff
			
func combine(abl : Ability):
	.combine(abl)
	buff += abl.buff
	desc = "This creature gives your other creatures on board +" + str(buff) + "/+" + str(buff) + " when it dies"

func _to_string():
	return name + " x" + str(buff) +" - " + desc

func clone(card : Card) -> Ability:
	var abl = get_script().new(card)
	abl.buff = buff
	return abl
