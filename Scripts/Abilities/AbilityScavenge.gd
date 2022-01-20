extends Ability

class_name AbilityScavenge

var buff = 1

func _init(card : Card).("Scavenge", "Gain +1/+1 when another friendly creature dies", card):
	pass

func onOtherDeath(board, slot):
	card.power += buff
	card.toughness += buff

func combine(abl : Ability):
	.combine(abl)
	buff += abl.buff
	desc = "Gain +" + str(buff) + "/+" + str(buff) + " when another friendly creature dies"

func _to_string():
	return name + " x" + str(buff) +" - " + desc

func clone(card : Card) -> Ability:
	var abl = get_script().new(card)
	abl.buff = buff
	return abl
