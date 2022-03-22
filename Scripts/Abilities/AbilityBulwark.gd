extends Ability

class_name AbilityBulwark

func _init(card : Card).("Bulwark", card, Color.darkgray, false, Vector2(32, 48)):
	pass
	
func onBeingAttacked(board, attacker):
	board.abilityStack.append([get_script(), "onEffect", [attacker]])

static func onEffect(params):
	if is_instance_valid(params[0].cardNode):
		params[0].cardNode.card.toughness -= params[0].cardNode.card.power

func genDescription() -> String:
	return "Deals damage when attacked equal to the damage taken"
