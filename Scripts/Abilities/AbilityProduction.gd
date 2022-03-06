extends Ability

class_name AbilityProduction

func _init(card : Card).("Production", "When this creature is played, create a mech with no abilities. Removes this ability", card, Color.gray, true, Vector2(0, 0)):
	pass

func onEnter(board, slot):
	.onEnter(board, slot)
	onEffect(board)
	
func onEnterFromFusion(board, slot):
	.onEnterFromFusion(board, slot)
	onEffect(board)
			
func onEffect(board):
	if board.players[board.activePlayer].UUID == card.playerID:
		for i in range(count):
			var c = ListOfCards.getCard(5)
			c.abilities = []
			card.addCreatureToBoard(c, board)
			
	card.abilities.erase(self)
	
