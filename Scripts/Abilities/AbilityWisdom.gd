extends Ability

class_name AbilityWisdom

func _init(card : Card).("Wisedom", card, Color.blue, true, Vector2(0, 0)):
	pass

func onEnter(board, slot):
	.onEnter(board, slot)
	board.abilityStack.append([get_script(), "onDrawEffect", [board, card.playerID, count]])
	card.removeAbility(self)
	
func onEnterFromFusion(board, slot):
	.onEnterFromFusion(board, slot)
	board.abilityStack.append([get_script(), "onDrawEffect", [board, card.playerID, count]])
	card.removeAbility(self)
			
static func onDrawEffect(params : Array):
	for p in params[0].players:
		if p.UUID == params[1]:
			for i in range(params[2]):
				p.hand.drawCard()
			break

func genDescription() -> String:
	return "When this creature is played, draw " + str(count) + (" cards" if count > 1 else " card") + ". Removes this ability"
