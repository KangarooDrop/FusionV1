extends Ability

class_name AbilityPyroclast

func _init(card : Card).("Pyroclast", card, Color.red, true, Vector2(0, 0)):
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
			p.takeDamage(params[2], params[1].cardNode)
			break

func genDescription() -> String:
	return "When this creature is played, it deals " + str(count) + " damage to you"
