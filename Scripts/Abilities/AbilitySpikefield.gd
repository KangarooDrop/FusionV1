extends Ability

class_name AbilitySpikefield

func _init(card : Card).("Spikefield", card, Color.gray, true, Vector2(32, 64)):
	pass

func onOtherEnter(slot):
	if NodeLoc.getBoard().isOnBoard(card):
		if slot.playerID == card.playerID:
			addToStack("onEffect", [])

func onEffect(params):
	for p in NodeLoc.getBoard().players:
		if p.UUID == card.playerID:
			p.takeDamage(myVars.count, card.playerID)
			break

func genDescription(subCount = 0) -> String:
	return .genDescription() + "Whenever a creature you control enters the battlefield, you take " + str(myVars.count) + " damage"
