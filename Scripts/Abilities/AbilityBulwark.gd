extends Ability

class_name AbilityBulwark

func _init(card : Card).("Bulwark", card, Color.darkgray, false, Vector2(32, 48)):
	pass
	
func onTakeDamage(card):
	.onTakeDamage(card)
	card.toughness -= card.power

func genDescription(subCount = 0) -> String:
	return .genDescription() + "Deals damage when attacked equal to the damage taken"
