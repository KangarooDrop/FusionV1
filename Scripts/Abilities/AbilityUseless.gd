extends Ability

class_name AbilityUseless

func _init(card : Card).("Useless", card, Color.purple, false, Vector2(0, 0)):
	if card != null:
		card.canBePlayed = false

func genDescription(subCount = 0) -> String:
	return .genDescription() + "Cannot be played"
