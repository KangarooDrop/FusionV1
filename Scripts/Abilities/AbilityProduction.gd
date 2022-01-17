extends Ability

class_name AbilityProduction

func _init(card : Card).("Production", "This creature create a mech at the start of your turn", card):
	pass

func onStartOfTurn(board):
	.onStartOfTurn(board)
	card.addCreatureToBoard(ListOfCards.getCard(5), board)
