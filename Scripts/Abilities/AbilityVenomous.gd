extends Ability

class_name AbilityVenomous

func _init(card : Card).("Venomous", card, Color.brown, true, Vector2(16, 64)):
	pass

func genDescription() -> String:
	return "While attacking another creature, this creature has +" + str(count) + " power"
