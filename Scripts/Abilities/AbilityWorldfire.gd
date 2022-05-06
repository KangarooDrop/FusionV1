extends Ability

class_name AbilityWorldfire

func _init(card : Card).("Worldfire", card, Color.red, true, Vector2(32, 64)):
	pass

func onEndOfTurn():
	if NodeLoc.getBoard().isOnBoard(card) and NodeLoc.getBoard().players[NodeLoc.getBoard().activePlayer].UUID == card.playerID:
		addToStack("onEffect", [count])

func onEffect(params):
	for p in NodeLoc.getBoard().getAllPlayers():
		p.takeDamage(params[0], card)

func genDescription(subCount = 0) -> String:
	return .genDescription() + "At the end of its controller's turn, this card deals " + str(count) + " damage to each player"
