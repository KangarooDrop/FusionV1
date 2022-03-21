extends Ability

class_name AbilityConfigure

func _init(card : Card).("Configure", card, Color.blue, true, Vector2(0, 0)):
	pass

func onEnter(board, slot):
	.onEnter(board, slot)
	board.abilityStack.append([get_script(), "onEffect", [board, slot, count]])
	card.removeAbility(self)
	
func onEnterFromFusion(board, slot):
	.onEnterFromFusion(board, slot)
	board.abilityStack.append([get_script(), "onEffect", [board, slot, count]])
	card.removeAbility(self)

static func onEffect(params):
	for s in params[0].creatures[params[1].cardNode.slot.playerID]:
		if is_instance_valid(s.cardNode) and s != params[1]:
			s.cardNode.card.power += params[2]

func genDescription() -> String:
	return "When this creature is played, all other creatures you control gain +" + str(count) + " power. Removes this ability"
