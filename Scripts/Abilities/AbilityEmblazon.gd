extends Ability

class_name AbilityEmblazon

func _init(card : Card).("Emblazon", card, Color.red, true, Vector2(0, 0)):
	pass

func onDealDamage(slot):
	if is_instance_valid(slot.cardNode):
		slot.cardNode.card.addAbility(AbilitySoulblaze.new(slot.cardNode.card).setCount(count))

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creaure deals damage, inflict " + str(AbilitySoulblaze.new(null).setCount(count)) + " on the other creature"
