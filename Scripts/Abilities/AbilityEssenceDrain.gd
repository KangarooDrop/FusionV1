extends AbilityETB

class_name AbilityEssenceDrain

func _init(card : Card).("Essence Drain", card, Color.darkgray, true, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onEffect", [card, count - timesApplied])

static func onEffect(params):
	var n = 0
	for s in NodeLoc.getBoard().boardSlots:
		if is_instance_valid(s.cardNode) and s.cardNode.card != null and s != params[0].cardNode.slot:
			s.cardNode.card.power -= params[1]
			s.cardNode.card.toughness -= params[1]
			s.cardNode.card.maxToughness -= params[1]
			n += 1
			
	params[0].power += params[1] * n

func genDescription(subCount = 0) -> String:
	var strCount = str(count - subCount)
	return .genDescription() + "When this creature is played, all other creatures get -" + strCount + "/-" + strCount + ". Gain +" + strCount + " power for each creature affected"
