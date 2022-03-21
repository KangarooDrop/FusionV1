extends Ability

class_name AbilityEssenceDrain

func _init(card : Card).("Essence Drain", card, Color.black, true, Vector2(0, 0)):
	pass

func onEnter(board, slot):
	.onEnter(board, slot)
	board.abilityStack.append([get_script(), "onEffect", [board, card, count]])
	card.removeAbility(self)
	
func onEnterFromFusion(board, slot):
	.onEnterFromFusion(board, slot)
	board.abilityStack.append([get_script(), "onEffect", [board, card, count]])
	card.removeAbility(self)

static func onEffect(params):
	var n = 0
	for s in params[0].boardSlots:
		if is_instance_valid(s.cardNode) and s.cardNode.card != null and s != params[1].cardNode.slot:
			s.cardNode.card.power -= params[2]
			s.cardNode.card.toughness -= params[2]
			s.cardNode.card.maxToughness -= params[2]
			n += 1
			
	params[1].power += params[2] * n

func genDescription() -> String:
	var strCount = str(count)
	return "When this creature is played, all other creatures get -" + strCount + "/-" + strCount + ". Gain +" + strCount + " power for each creature affected. Removes this ability"
