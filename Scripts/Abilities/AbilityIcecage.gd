extends AbilityETB

class_name AbilityIcecage

func _init(card : Card).("Icecage", card, Color.blue, false, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onEffect", [])
			
static func onEffect(params):
	for s in NodeLoc.getBoard().boardSlots:
		if is_instance_valid(s.cardNode) and s.cardNode.card != null:
			var frozen = AbilityFrozen.new(s.cardNode.card)
			frozen.onEffect()
			s.cardNode.card.addAbility(frozen)

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creature is played, inflict " + str(AbilityFrozen.new(null)) + " on all creatures"
