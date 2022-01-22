extends Ability

class_name AbilityProduction

func _init(card : Card).("Production", "This creature creates a mech at the start of your turn", card, Color.gray, true):
	pass

func onStartOfTurn(board):
	.onStartOfTurn(board)
	if board.players[board.activePlayer].UUID == card.playerID:
		for i in range(count):
			card.addCreatureToBoard(ListOfCards.getCard(5), board)
	
func combine(abl : Ability):
	.combine(abl)
	desc = "This creature create " + str(count) + " mechs at the start of your turn"
