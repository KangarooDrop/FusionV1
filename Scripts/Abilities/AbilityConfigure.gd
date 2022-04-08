extends AbilityETB

class_name AbilityConfigure

func _init(card : Card).("Configure", card, Color.gray, true, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onEffect", [slot, count - timesApplied])
	
static func onEffect(params):
	for s in NodeLoc.getBoard().creatures[params[0].playerID]:
		if is_instance_valid(s.cardNode) and s != params[0]:
			s.cardNode.card.power += params[1]

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creature is played, all other creatures you control gain +" + str(count - subCount) + " power"
