extends Ability

class_name AbilityBioagent

func _init(card : Card).("Bioagent", card, Color.darkgray, true, Vector2(0, 96)):
	pass

func onDeath():
	.onDeath()
	addToStack("onEffect", [card.cardNode.slot])

func onEffect(params):
	for s in params[0].getNeighbors():
		if is_instance_valid(s.cardNode):
			s.cardNode.card.toughness -= myVars.count

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creature dies, it deals " + str(myVars.count) +" damage to each adjacent creature"
