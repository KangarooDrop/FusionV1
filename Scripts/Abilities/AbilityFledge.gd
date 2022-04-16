extends AbilityETB

class_name AbilityFledge

func _init(card : Card).("Fledge", card, Color.gold, false, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onEffect", [card, slot.getNeighbors()])

static func onEffect(params):
	for s in params[1]:
		var card = ListOfCards.getCard(84)
		params[0].addCreatureToBoard(card, s)

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creature is played, create a 0/0 ooze on either side of it"
