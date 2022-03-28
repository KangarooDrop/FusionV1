extends Ability

class_name AbilityShieldUp

func _init(card : Card).("Shield Up", card, Color.darkgray, true, Vector2(0, 0)):
	pass

func onEnter(slot):
	.onEnter(slot)
	addToStack("onEffect", [card, count])
	card.removeAbility(self)

func onEnterFromFusion(slot):
	.onEnterFromFusion(slot)
	addToStack("onEffect", [card, count])
	card.removeAbility(self)
	
static func onEffect(params):
	for p in NodeLoc.getBoard().players:
		if p.UUID == params[0].playerID:
			p.addArmour(params[1])

func genDescription() -> String:
	return .genDescription() + "When this creature is played, gain " + str(count) + " " + str(TextArmor.new(null)) + ". Removes this ability"
