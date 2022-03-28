extends Ability

class_name AbilityPyroclast

func _init(card : Card).("Pyroclast", card, Color.red, true, Vector2(0, 0)):
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
			p.takeDamage(params[1], params[0].cardNode)
			break

func genDescription() -> String:
	return .genDescription() + "When this creature is played, it deals " + str(count) + " damage to you"
