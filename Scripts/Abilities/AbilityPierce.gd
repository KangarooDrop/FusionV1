extends AbilityETB

class_name AbilityPierce

var discardIndexes := []

func _init(card : Card).("Pierce", card, Color.red, false, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onEffect", [card, card.playerID])

static func onEffect(params : Array):
	for p in NodeLoc.getBoard().players:
		if p.UUID != params[1]:
			p.takeDamage(params[0].power, params[0])
	
func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creature is played, it deals damage equal to its power to the opponent"
