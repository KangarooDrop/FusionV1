extends Ability

class_name AbilityBrittle

func _init(card : Card).("Brittle", "At the start of your turn, this creature is destroyed.", card, Color.gray, false):
	pass

func onStartOfTurn(board):
	if board.players[board.activePlayer].UUID == card.playerID:
		card.toughness = 0
		board.checkState()
