extends Ability

class_name AbilityTough

func _init(card : Card).("Tough", card, Color.darkgray, true, Vector2(0, 48)):
	pass

func onBeforeDamage(attacker, blocker):
	if blocker == card.cardNode.slot:
		addToStack("onEffect", [card, count])

static func onEffect(params):
	params[0].power += params[1]
	params[0].toughness += params[1]
	params[0].maxToughness += params[1]

func genDescription(subCount = 0) -> String:
	return .genDescription() + "This creature gains +" + str(count) + "/+" + str(count) + " when attacked"
