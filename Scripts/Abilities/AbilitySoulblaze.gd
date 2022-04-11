extends Ability

class_name AbilitySoulblaze

func _init(card : Card).("Soulblaze", card, Color.red, true, Vector2(32, 64)):
	pass

func onEndOfTurn():
	if NodeLoc.getBoard().isOnBoard(card) and NodeLoc.getBoard().players[NodeLoc.getBoard().activePlayer].UUID == card.playerID:
		addToStack("onEffect", [card, card.cardNode.slot.playerID])

func onEffect(params):
	var board = NodeLoc.getBoard()
	if board.isOnBoard(params[0]):
		var d = card.toughness
		for p in board.players:
			if p.UUID == params[1]:
				p.takeDamage(d, params[0])
				
		params[0].toughness -= d

func genDescription(subCount = 0) -> String:
	return .genDescription() + "At the end of your turn, this creature and its controller take damage equal to its toughness"
