extends Ability

class_name AbilityInfested

func _init(card : Card).("Infested", card, Color.black, true, Vector2(32, 96)):
	pass

func onDeath(board):
	.onDeath(board)
	board.abilityStack.append([get_script(), "onEffect", [board, card, count]])

static func onEffect(params):
	for i in range(params[2]):
		var card = ListOfCards.getCard(21)
		card.abilities.clear()
		card.power = 1
		card.toughness = 1
		params[1].addCreatureToBoard(card, params[0], null)

func genDescription() -> String:
	return "When this creature dies, creates " + str(count) + " 1/1 Necro with no abilities"
