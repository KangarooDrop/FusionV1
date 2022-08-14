extends AbilityETB

class_name AbilityEssenceDrain

func _init(card : Card).("Essence Drain", card, Color.darkgray, true, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onEffect", [])

func onEffect(params):
	var n = 0
	for s in NodeLoc.getBoard().boardSlots:
		if is_instance_valid(s.cardNode) and s.cardNode.card != null and (not is_instance_valid(card.cardNode) or not is_instance_valid(card.cardNode.slot) or s != card.cardNode.slot):
			s.cardNode.card.power -= myVars.count - myVars.timesApplied
			s.cardNode.card.toughness -= myVars.count - myVars.timesApplied
			s.cardNode.card.maxToughness -= myVars.count - myVars.timesApplied
			n += 1
			
	card.power += (myVars.count - myVars.timesApplied) * n
	myVars.timesApplied = myVars.count

func genDescription(subCount = 0) -> String:
	var strCount = str(myVars.count - subCount)
	return .genDescription() + "When this creature is played, all other creatures get -" + strCount + "/-" + strCount + ". Gain +" + strCount + " power for each creature affected"
