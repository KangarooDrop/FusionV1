extends AbilityETB

class_name AbilityShieldUp

func _init(card : Card).("Shield Up", card, Color.darkgray, true, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onEffect", [])
	
func onEffect(params):
	for p in NodeLoc.getBoard().players:
		if p.UUID == card.playerID:
			p.addArmour(count - timesApplied)
	timesApplied = count

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creature is played, its controller gains " + str(count - subCount) + " " + str(TextArmor.new(null))
