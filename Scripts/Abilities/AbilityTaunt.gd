extends Ability

class_name AbilityTaunt

func _init(card : Card).("Taunt", card, Color.darkgray, false, Vector2(0, 0)):
	pass

func genDescription() -> String:
	return "This creature must be the target of enemy attacks"
