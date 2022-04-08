extends Ability

class_name AbilityPurify

func _init(card : Card).("Purify", card, Color.purple, false, Vector2(0, 16)):
	pass
	
func onFusion(card):
	for abl in card.abilities.duplicate():
		card.removeAbility(abl)

func genDescription(subCount = 0) -> String:
	return .genDescription() + "On fusion, removes all abilities"
