extends Ability

class_name AbilityTough

func _init(card : Card).("Tough", card, Color.darkgray, true, Vector2(0, 48)):
	pass

func onBeforeDamage(attacker, blocker):
	if blocker == card.cardNode.slot:
		addToStack("onEffect", [])

func onEffect(params):
	card.power += count
	card.toughness += count
	card.maxToughness += count

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When attacked, this creature gains +" + str(count) + "/+" + str(count)
