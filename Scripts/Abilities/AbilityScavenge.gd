extends Ability

class_name AbilityScavenge

func _init(card : Card).("Scavenge", card, Color.black, true, Vector2(16, 96)):
	pass

func onOtherDeath(board, slot):
	card.power += count
	card.toughness += count

func genDescription() -> String:
	return "Gain +" + str(count) + "/+" + str(count) + " when another friendly creature dies"
