extends Ability

class_name AbilityDegenerate

func _init(card : Card).("Degenerate", card, Color.purple, false, Vector2(0, 0)):
	pass

func onFusion():
	for abl in card.abilities:
		if abl is get_script():
			card.creatureType = [Card.CREATURE_TYPE.Null]
			break

func genDescription(subCount = 0) -> String:
	return .genDescription() + "On fusion, the card loses all creature types"
