extends AbilityETB

class_name AbilityProduction

func _init(card : Card).("Production", card, Color.gray, true, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onEffect", [card, count - timesApplied])

static func onEffect(params):
	for i in range(params[1]):
		var card = ListOfCards.getCard(5)
		card.abilities[0].timesApplied = 1
		params[0].addCreatureToBoard(card, null)

func genDescription(subCount = 0) -> String:
	var string = "a"
	if count > 1:
		string = str(count - subCount)
	return .genDescription() + "When this creature is played, create " + string +" 1/1 mech with no abilities"
