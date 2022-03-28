extends Ability

class_name AbilitySacrifice

func _init(card : Card).("Sacrifice", card, Color.darkgray, true, Vector2(0, 96)):
	pass

func onDeath():
	.onDeath()
	addToStack("onEffect", [card, count])

static func onEffect(params):
	for slot in NodeLoc.getBoard().creatures[params[0].playerID]:
		if is_instance_valid(slot.cardNode):
			slot.cardNode.card.power += params[1]
			slot.cardNode.card.toughness += params[1]

func genDescription() -> String:
	return .genDescription() + "This creature gives your other creatures on board +" + str(count) + "/+" + str(count) + " when it dies"
