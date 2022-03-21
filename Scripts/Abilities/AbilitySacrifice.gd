extends Ability

class_name AbilitySacrifice

func _init(card : Card).("Sacrifice", card, Color.black, true, Vector2(0, 96)):
	pass

func onDeath(board):
	.onDeath(board)
	board.abilityStack.append([get_script(), "onEffect", [board, card, count]])

static func onEffect(params):
	for slot in params[0].creatures[params[1].playerID]:
		if is_instance_valid(slot.cardNode):
			slot.cardNode.card.power += params[2]
			slot.cardNode.card.toughness += params[2]

func genDescription() -> String:
	return "This creature gives your other creatures on board +" + str(count) + "/+" + str(count) + " when it dies"
