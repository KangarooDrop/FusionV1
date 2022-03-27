extends Ability

class_name AbilityEvolution

func _init(card : Card).("Evolution", card, Color.brown, true, Vector2(32, 64)):
	pass

func onEndOfTurn():
	if NodeLoc.getBoard().isOnBoard(card) and NodeLoc.getBoard().players[NodeLoc.getBoard().activePlayer].UUID == card.playerID:
		card.power += count
		card.toughness += count

func genDescription() -> String:
	return .genDescription() + "At the end of your turn, this card gains +" + str(count) + "/+" + str(count)
