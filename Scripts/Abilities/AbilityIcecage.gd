extends Ability

class_name AbilityIcecage

func _init(card : Card).("Icecage", card, Color.blue, true, Vector2(0, 0)):
	pass

func onEnter(slot):
	.onEnter(slot)
	addToStack("onEffect", [])
	card.removeAbility(self)
	
func onEnterFromFusion(slot):
	.onEnterFromFusion(slot)
	addToStack("onEffect", [])
	card.removeAbility(self)
			
static func onEffect(params):
	for s in NodeLoc.getBoard().boardSlots:
		if is_instance_valid(s.cardNode) and s.cardNode.card != null:
			var frozen = AbilityFrozen.new(s.cardNode.card)
			frozen.onEffect()
			s.cardNode.card.addAbility(frozen)

func genDescription() -> String:
	return .genDescription() + "When this creature is played, inflict " + str(AbilityFrozen.new(null)) + " on all creatures. Removes this ability"
