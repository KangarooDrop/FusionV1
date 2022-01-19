extends Ability

class_name AbilityScavenge

func _init(card : Card).("Scavenge", "Gain +1/+1 when another friendly creature dies", card):
	pass

func onOtherDeath(board, slot):
	card.power += 1
	card.toughness += 1
