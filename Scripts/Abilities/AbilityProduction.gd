extends Ability

class_name AbilityProduction

func _init(card : Card).("Production", "This creature creates a mech on being played", card, Color.gray, true):
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
			
	var scr = get_script()
	for abl in card.abilities:
		if abl is scr:
			card.abilities.erase(abl)
			break
	
