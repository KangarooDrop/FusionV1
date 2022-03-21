extends Ability

class_name AbilityBrittle

func _init(card : Card).("Brittle", card, Color.gray, false, Vector2(16, 80)):
	pass

func onEndOfTurn(board):
	if board.isOnBoard(card):
		board.abilityStack.append([get_script(), "onEffect", [card]])

static func onEffect(params):
	params[0].toughness = -INF
	
func genDescription() -> String:
	return "At the end of the turn, this creature is destroyed."
