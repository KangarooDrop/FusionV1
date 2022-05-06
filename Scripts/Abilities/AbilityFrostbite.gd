extends Ability

class_name AbilityFrostbite

func _init(card : Card).("Frostbite", card, Color.blue, false, Vector2(0, 32)):
	pass
	
func onDealDamage(slot):
	if is_instance_valid(slot.cardNode):
		addToStack("onEffect", [slot.cardNode.card])

static func onEffect(params):
	if ListOfCards.isInZone(params[0], CardSlot.ZONES.CREATURE):
		var frozen = AbilityFrozen.new(params[0])
		frozen.onEffect()
		params[0].addAbility(frozen)

func genDescription(subCount = 0) -> String:
	return .genDescription() + "Inflicts " + str(AbilityFrozen.new(null)) + " on the enemy creature when this creature attacks or is attacked"
