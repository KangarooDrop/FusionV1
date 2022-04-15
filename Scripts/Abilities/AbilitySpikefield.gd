extends Ability

class_name AbilitySpikefield

func _init(card : Card).("Spikefield", card, Color.gray, true, Vector2(32, 64)):
	pass

func onOtherEnter(slot):
	if NodeLoc.getBoard().isOnBoard(card):
		if slot.playerID == card.playerID:
			addToStack("onEffect", [slot.cardNode.card, count])

func onEffect(params):
	params[0].toughness -= params[1]

func genDescription(subCount = 0) -> String:
	return .genDescription() + "Whenever a creature you control enters the battlefield, it takes " + str(count) + " damage"
