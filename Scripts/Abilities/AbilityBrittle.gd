extends Ability

class_name AbilityBrittle

func _init(card : Card).("Brittle", "At the end of the turn, this creature is destroyed.", card, Color.gray, false, Vector2(16, 80)):
	pass

func onEndOfTurn(board):
	card.toughness = -INF
	board.checkState()
