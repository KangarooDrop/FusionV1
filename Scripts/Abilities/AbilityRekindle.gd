extends Ability

class_name AbilityRekindle

func _init(card : Card).("Rekindle", card, Color.red, true, Vector2(0, 0)):
	pass

func onEnter(slot):
	.onEnter(slot)
	NodeLoc.getBoard().abilityStack.append([get_script(), "onEffect", [card.playerID, count]])
	card.removeAbility(self)
	
func onEnterFromFusion(slot):
	.onEnterFromFusion(slot)
	NodeLoc.getBoard().abilityStack.append([get_script(), "onEffect", [card.playerID, count]])
	card.removeAbility(self)

static func onEffect(params : Array):
	for p in NodeLoc.getBoard().players:
		if p.UUID == params[0]:
			var n = min(p.hand.nodes.size(), params[1])
			for i in range(n):
				p.hand.discardIndex(i)
				
			for i in range(params[1]):
				p.hand.drawCard()
			break
	
func genDescription() -> String:
	return "When this creature is played, discard your " + str(count) + " leftmost cards and then draw " + str(count) + " cards. Removes this ability"
