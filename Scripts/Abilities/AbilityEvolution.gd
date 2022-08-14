extends Ability

class_name AbilityEvolution

func _init(card : Card).("Evolution", card, Color.brown, true, Vector2(32, 64)):
	pass

func onEndOfTurn():
	if NodeLoc.getBoard().isOnBoard(card) and NodeLoc.getBoard().players[NodeLoc.getBoard().activePlayer].UUID == card.playerID:
		card.power += myVars.count
		card.toughness += myVars.count
		card.maxToughness += myVars.count

func genDescription(subCount = 0) -> String:
	return .genDescription() + "At the end of your turn, this card gains +" + str(myVars.count) + "/+" + str(myVars.count)
