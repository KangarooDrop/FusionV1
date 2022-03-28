extends Ability

class_name AbilityConfigure

func _init(card : Card).("Configure", card, Color.gray, true, Vector2(0, 0)):
	pass

func onEnter(slot):
	.onEnter(slot)
	addToStack("onEffect", [slot, count])
	card.removeAbility(self)
	
func onEnterFromFusion(slot):
	.onEnterFromFusion(slot)
	addToStack("onEffect", [slot, count])
	card.removeAbility(self)

static func onEffect(params):
	for s in NodeLoc.getBoard().creatures[params[0].cardNode.slot.playerID]:
		if is_instance_valid(s.cardNode) and s != params[0]:
			s.cardNode.card.power += params[1]

func genDescription() -> String:
	return .genDescription() + "When this creature is played, all other creatures you control gain +" + str(count) + " power. Removes this ability"
