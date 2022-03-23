extends Ability

class_name AbilityWisdom

func _init(card : Card).("Wisedom", card, Color.blue, true, Vector2(0, 0)):
	pass

func onEnter(slot):
	.onEnter(slot)
	NodeLoc.getBoard().abilityStack.append([get_script(), "onDrawEffect", [card.playerID, count]])
	card.removeAbility(self)
	
func onEnterFromFusion(slot):
	.onEnterFromFusion(slot)
	NodeLoc.getBoard().abilityStack.append([get_script(), "onDrawEffect", [card.playerID, count]])
	card.removeAbility(self)
			
static func onDrawEffect(params : Array):
	for p in NodeLoc.getBoard().players:
		if p.UUID == params[0]:
			for i in range(params[1]):
				p.hand.drawCard()
			break

func genDescription() -> String:
	return "When this creature is played, draw " + str(count) + (" cards" if count > 1 else " card") + ". Removes this ability"
