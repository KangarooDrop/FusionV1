extends Ability

class_name AbilityInsignia

func _init(card : Card).("Insignia", card, Color.red, true, Vector2(0, 0)):
	pass

func onEnter(slot):
	.onEnter(slot)
	NodeLoc.getBoard().abilityStack.append([get_script(), "onEffect", []])
	card.removeAbility(self)
	
func onEnterFromFusion(slot):
	.onEnterFromFusion(slot)
	NodeLoc.getBoard().abilityStack.append([get_script(), "onEffect", []])
	card.removeAbility(self)
			
static func onEffect(params):
	for s in NodeLoc.getBoard().boardSlots:
		if is_instance_valid(s.cardNode) and s.cardNode.card != null:
			s.cardNode.card.addAbility(AbilitySoulblaze.new(s.cardNode.card))

func genDescription() -> String:
	return .genDescription() + "When this creature is played, inflict " + str(AbilitySoulblaze.new(null)) + " on all creatures. Removes this ability"
