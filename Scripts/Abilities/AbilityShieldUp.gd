extends Ability

class_name AbilityShieldUp

func _init(card : Card).("Shield Up", card, Color.darkgray, true, Vector2(0, 0)):
	pass

func onEnter(board, slot):
	.onEnter(board, slot)
	board.abilityStack.append([get_script(), "onEffect", [board, card, count]])
	card.removeAbility(self)

func onEnterFromFusion(board, slot):
	.onEnterFromFusion(board, slot)
	board.abilityStack.append([get_script(), "onEffect", [board, card, count]])
	card.removeAbility(self)
	
static func onEffect(params):
	for p in params[0].players:
		if p.UUID == params[1].playerID:
			p.addArmour(params[2])

func genDescription() -> String:
	return "When this creature is played, gain " + str(count) + " " + str(TextArmor.new(null)) + ". Removes this ability"
