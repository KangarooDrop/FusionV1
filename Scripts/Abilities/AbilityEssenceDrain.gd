extends Ability

class_name AbilityEssenceDrain

func _init(card : Card).("Essence Drain", card, Color.black, true, Vector2(0, 0)):
	pass

func onEnter(slot):
	.onEnter(slot)
	NodeLoc.getBoard().abilityStack.append([get_script(), "onEffect", [card, count]])
	card.removeAbility(self)
	
func onEnterFromFusion(slot):
	.onEnterFromFusion(slot)
	NodeLoc.getBoard().abilityStack.append([get_script(), "onEffect", [card, count]])
	card.removeAbility(self)

static func onEffect(params):
	var n = 0
	for s in NodeLoc.getBoard().boardSlots:
		if is_instance_valid(s.cardNode) and s.cardNode.card != null and s != params[0].cardNode.slot:
			s.cardNode.card.power -= params[1]
			s.cardNode.card.toughness -= params[1]
			s.cardNode.card.maxToughness -= params[1]
			n += 1
			
	params[0].power += params[1] * n

func genDescription() -> String:
	var strCount = str(count)
	return "When this creature is played, all other creatures get -" + strCount + "/-" + strCount + ". Gain +" + strCount + " power for each creature affected. Removes this ability"
