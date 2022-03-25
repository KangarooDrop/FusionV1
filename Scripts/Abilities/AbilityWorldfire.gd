extends Ability

class_name AbilityWorldfire

func _init(card : Card).("Worldfire", card, Color.red, true, Vector2(32, 64)):
	pass

func onEndOfTurn():
	if NodeLoc.getBoard().isOnBoard(card) and NodeLoc.getBoard().players[NodeLoc.getBoard().activePlayer].UUID == card.playerID:
		NodeLoc.getBoard().abilityStack.append([get_script(), "onEffect", [card, count]])

static func onEffect(params):
	for p in NodeLoc.getBoard().getAllPlayers():
		p.takeDamage(params[1], params[0])

func genDescription() -> String:
	return "At the end of your turn, this card deals " + str(count) + " damage to each player"
