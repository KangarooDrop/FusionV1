extends Ability

class_name AbilityRampage

func _init(card : Card).("Rampage", card, Color.brown, false,Vector2(0, 64)):
	pass

func genDescription() -> String:
	return "When attacking a creature, excess damage is dealt to its owner"
