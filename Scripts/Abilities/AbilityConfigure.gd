extends AbilityETB

class_name AbilityConfigure

func _init(card : Card).("Configure", card, Color.gray, true, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onEffect", [count - timesApplied])
	
func onEffect(params):
	for s in NodeLoc.getBoard().creatures[params[0].playerID]:
		if is_instance_valid(s.cardNode) and (not is_instance_valid(params[0].cardNode) or not is_instance_valid(card.cardNode.slot) or s != card.cardNode.slot):
			s.cardNode.card.power += params[0]

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creature is played, all other creatures its controller has gain +" + str(count - subCount) + " power"
