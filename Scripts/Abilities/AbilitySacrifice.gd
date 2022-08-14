extends Ability

class_name AbilitySacrifice

func _init(card : Card).("Sacrifice", card, Color.darkgray, true, Vector2(0, 96)):
	pass

func onDeath():
	.onDeath()
	addToStack("onEffect", [])

func onEffect(params):
	for slot in NodeLoc.getBoard().creatures[card.playerID]:
		if is_instance_valid(slot.cardNode):
			slot.cardNode.card.power += myVars.count
			slot.cardNode.card.toughness += myVars.count
			slot.cardNode.card.maxToughness += myVars.count

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creature dies, it gives other creatures you control +" + str(myVars.count) + "/+" + str(myVars.count)
