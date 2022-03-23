extends Ability

class_name AbilityInfested

func _init(card : Card).("Infested", card, Color.black, true, Vector2(32, 96)):
	pass

func onDeath():
	.onDeath()
	NodeLoc.getBoard().abilityStack.append([get_script(), "onEffect", [card, count]])

static func onEffect(params):
	for i in range(params[1]):
		var card = ListOfCards.getCard(21)
		card.abilities.clear()
		card.power = 1
		card.toughness = 1
		params[0].addCreatureToBoard(card, null)

func genDescription() -> String:
	return "When this creature dies, creates " + str(count) + " 1/1 Necro with no abilities"
