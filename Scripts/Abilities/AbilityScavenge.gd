extends Ability

class_name AbilityScavenge

func _init(card : Card).("Scavenge", "Gain +1/+1 when another friendly creature dies", card, Color.black, false):
	pass

func onOtherDeath(board, slot):
	card.power += count
	card.toughness += count

func combine(abl : Ability):
	.combine(abl)
	desc = "Gain +" + str(count) + "/+" + str(count) + " when another friendly creature dies"
