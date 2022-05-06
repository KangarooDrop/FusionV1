extends AbilityETB

class_name AbilityPyroclast

func _init(card : Card).("Pyroclast", card, Color.red, true, Vector2(0, 0)):
	pass
	
func onApplied(slot):
	addToStack("onEffect", [count - timesApplied])

func onEffect(params):
	for p in NodeLoc.getBoard().players:
		if p.UUID == card.playerID:
			p.takeDamage(params[0], card)
			break

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creature is played, it deals " + str(count - subCount) + " damage to its controller"
