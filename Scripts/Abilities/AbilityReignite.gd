extends Ability

class_name AbilityReignite

func _init(card : Card).("Reignite", card, Color.red, false, Vector2(0, 0)):
	pass

func onEnter(board, slot):
	.onEnter(board, slot)
	board.abilityStack.append([get_script(), "onEffect", [board, card.playerID]])
	card.removeAbility(self)
	
func onEnterFromFusion(board, slot):
	.onEnterFromFusion(board, slot)
	board.abilityStack.append([get_script(), "onEffect", [board, card.playerID]])
	card.removeAbility(self)

static func onEffect(params : Array):
	for p in params[0].players:
		if p.UUID == params[1]:
			var cardsDiscarded = p.hand.nodes.size()
			for i in range(cardsDiscarded):
				p.hand.discardIndex(i)
				
			for i in range(cardsDiscarded):
				p.hand.drawCard()
			break
	
func genDescription() -> String:
	return "When this creature is played, discard your hand and then draw that many cards. Removes this ability"
