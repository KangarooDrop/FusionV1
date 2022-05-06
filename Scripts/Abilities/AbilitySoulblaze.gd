extends Ability

class_name AbilitySoulblaze

func _init(card : Card).("Soulblaze", card, Color.red, false, Vector2(32, 64)):
	pass

func onEndOfTurn():
	if NodeLoc.getBoard().isOnBoard(card) and NodeLoc.getBoard().players[NodeLoc.getBoard().activePlayer].UUID == card.playerID:
		addToStack("onEffect", [])

func onEffect(params):
	var board = NodeLoc.getBoard()
	if board.isOnBoard(card):
		var d = card.toughness
		for p in board.players:
			if p.UUID == card.playerID:
				p.takeDamage(d, card)
				
		card.isDying = true

func genDescription(subCount = 0) -> String:
	return .genDescription() + "At the end of its controller's turn, destroy this creature and its controller takes damage equal to its toughness"
