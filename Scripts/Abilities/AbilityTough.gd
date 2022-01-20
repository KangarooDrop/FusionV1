extends Ability

class_name AbilityTough

var buff = 1

func _init(card : Card).("Tough", "This creature gains +1/+1 when attacked", card):
	pass

func onBeingAttacked(attacker, board):
	.onBeingAttacked(attacker, board)
	card.power += buff
	card.toughness += buff

func combine(abl : Ability):
	.combine(abl)
	buff += abl.buff
	desc = "This creature gains +" + str(buff) + "/+" + str(buff) + " when attacked"

func _to_string():
	return name + " x" + str(buff) +" - " + desc

func clone(card : Card) -> Ability:
	var abl = get_script().new(card)
	abl.buff = buff
	return abl
