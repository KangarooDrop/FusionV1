extends Ability

class_name AbilitySoulblaze

func _init(card : Card).("Soulblaze", card, Color.red, false, Vector2(32, 64)):
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
				
		params[0].isDying = true

func genDescription(subCount = 0) -> String:
	return .genDescription() + "At the end of its controller's turn, destroy this creature and its controller takes damage equal to its toughness"
