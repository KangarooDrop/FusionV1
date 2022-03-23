extends Ability

class_name AbilityRekindle

func _init(card : Card).("Rekindle", card, Color.red, true, Vector2(0, 0)):
	pass

func onEnter(board, slot):
	.onEnter(board, slot)
	board.abilityStack.append([get_script(), "onEffect", [board, card.playerID, count]])
	card.removeAbility(self)
	
func onEnterFromFusion(board, slot):
	.onEnterFromFusion(board, slot)
	board.abilityStack.append([get_script(), "onEffect", [board, card.playerID, count]])
	card.removeAbility(self)

static func onEffect(params : Array):
	for p in params[0].players:
		if p.UUID == params[1]:
			var n = min(p.hand.nodes.size(), params[2])
			for i in range(n):
				p.hand.discardIndex(i)
				
			for i in range(params[2]):
				p.hand.drawCard()
			break
	
func genDescription() -> String:
	return "When this creature is played, discard your " + str(count) + " leftmost cards and then draw " + str(count) + " cards. Removes this ability"
