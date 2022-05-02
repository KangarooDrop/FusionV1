extends Ability

class_name AbilityBrittle

func _init(card : Card).("Brittle", card, Color.gray, false, Vector2(16, 80)):
	pass

func onEndOfTurn():
	if NodeLoc.getBoard().isOnBoard(card):
		addToStack("onEffect", [card])

static func onEffect(params):
	params[0].isDying = true
	
func genDescription(subCount = 0) -> String:
	return .genDescription() + "At the end of the turn, this creature is destroyed."
