extends Ability

class_name AbilityIcecage

func _init(card : Card).("Icecage", card, Color.blue, true, Vector2(0, 0)):
	pass

func onEnter(board, slot):
	.onEnter(board, slot)
	board.abilityStack.append([get_script(), "onEffect", [board]])
	card.removeAbility(self)
	
func onEnterFromFusion(board, slot):
	.onEnterFromFusion(board, slot)
	board.abilityStack.append([get_script(), "onEffect", [board]])
	card.removeAbility(self)
			
static func onEffect(params):
	for s in params[0].boardSlots:
		if is_instance_valid(s.cardNode) and s.cardNode.card != null:
			var frozen = AbilityFrozen.new(s.cardNode.card)
			frozen.onEffect()
			s.cardNode.card.addAbility(frozen)

func genDescription() -> String:
	return "When this creature is played, inflict " + str(AbilityFrozen.new(null)) + " on all creatures. Removes this ability"
