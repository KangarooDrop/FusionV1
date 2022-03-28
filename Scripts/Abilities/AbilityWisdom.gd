extends Ability

class_name AbilityWisdom

func _init(card : Card).("Wisedom", card, Color.blue, true, Vector2(0, 0)):
	pass

func onEnter(slot):
	.onEnter(slot)
	addToStack("onEffect", [card.playerID, count])
	card.removeAbility(self)
	
func onEnterFromFusion(slot):
	.onEnterFromFusion(slot)
	addToStack("onEffect", [card.playerID, count])
	card.removeAbility(self)
			
static func onEffect(params : Array):
	for p in NodeLoc.getBoard().players:
		if p.UUID == params[0]:
			for i in range(params[1]):
				p.hand.drawCard()
			break

func genDescription() -> String:
	return .genDescription() + "When this creature is played, draw " + str(count) + (" cards" if count > 1 else " card") + ". Removes this ability"
