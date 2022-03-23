extends Ability

class_name AbilityFrostbite

func _init(card : Card).("Frostbite", card, Color.blue, false, Vector2(0, 32)):
	pass
	
func onAttack(blocker):
	NodeLoc.getBoard().abilityStack.append([get_script(), "onEffect", [blocker]])
	
func onBeingAttacked(attacker):
	NodeLoc.getBoard().abilityStack.append([get_script(), "onEffect", [attacker]])

static func onEffect(params):
	if is_instance_valid(params[0].cardNode):
		var frozen = AbilityFrozen.new(params[0].cardNode.card)
		frozen.onEffect()
		params[0].cardNode.card.addAbility(frozen)

func genDescription() -> String:
	return "Inflicts " + str(AbilityFrozen.new(null)) + " on the enemy creature when this creature attacks or is attacked"
