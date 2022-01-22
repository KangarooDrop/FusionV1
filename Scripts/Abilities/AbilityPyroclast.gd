extends Ability

class_name AbilityPyroclast

func _init(card : Card).("Pyroclast", "Deals an additional damage to players", card, Color.red, true):
	pass
	
func combine(abl : Ability):
	.combine(abl)
	desc = "Deals an additional " + str(count) + " damage to players"
