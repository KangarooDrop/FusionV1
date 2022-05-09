extends AbilityETB

class_name AbilityConfigure

func _init(card : Card).("Configure", card, Color.gray, true, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onEffect", [])
	
func onEffect(params):
	for s in NodeLoc.getBoard().creatures[card.playerID]:
		if is_instance_valid(s.cardNode) and (not is_instance_valid(card.cardNode) or not is_instance_valid(card.cardNode.slot) or s != card.cardNode.slot):
			s.cardNode.card.power += count - timesApplied
	timesApplied = count

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creature is played, all other creatures its controller has gain +" + str(count - subCount) + " power"
