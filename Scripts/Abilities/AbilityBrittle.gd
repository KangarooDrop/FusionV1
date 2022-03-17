extends Ability

class_name AbilityBrittle

func _init(card : Card).("Brittle", card, Color.gray, false, Vector2(16, 80)):
	pass

func onEndOfTurn(board):
	card.toughness = -INF
	board.checkState()
	
func genDescription() -> String:
	return "At the end of the turn, this creature is destroyed."
