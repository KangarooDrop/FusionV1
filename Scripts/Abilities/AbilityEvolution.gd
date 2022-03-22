extends Ability

class_name AbilityEvolution

func _init(card : Card).("Evolution", card, Color.brown, true, Vector2(32, 64)):
	pass

func onEndOfTurn(board):
	if board.isOnBoard(card) and board.players[board.activePlayer].UUID == card.cardNode.playerID:
		card.power += count
		card.toughness += count

func genDescription() -> String:
	return "At the end of your turn, this card gains +" + str(count) + "/+" + str(count)
