extends Ability

class_name AbilityScavenge

func _init(card : Card).("Scavenge", card, Color.darkgray, true, Vector2(16, 96)):
	pass

func onOtherDeath(slot):
	if NodeLoc.getBoard().isOnBoard(card) and card.playerID == slot.playerID:
		addToStack("onEffect", [card, count])

static func onEffect(params):
	params[0].power += params[1]
	params[0].toughness += params[1]

func genDescription(subCount = 0) -> String:
	return .genDescription() + "Gain +" + str(count) + "/+" + str(count) + " when another friendly creature dies"
