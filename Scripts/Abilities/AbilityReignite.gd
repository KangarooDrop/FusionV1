extends Ability

class_name AbilityReignite

func _init(card : Card).("Reignite", card, Color.red, false, Vector2(0, 0)):
	pass

func onEnter(slot):
	.onEnter(slot)
	NodeLoc.getBoard().abilityStack.append([get_script(), "onEffect", [card.playerID]])
	card.removeAbility(self)
	
func onEnterFromFusion(slot):
	.onEnterFromFusion(slot)
	NodeLoc.getBoard().abilityStack.append([get_script(), "onEffect", [card.playerID]])
	card.removeAbility(self)

static func onEffect(params : Array):
	for p in NodeLoc.getBoard().players:
		if p.UUID == params[0]:
			var cardsDiscarded = p.hand.nodes.size()
			for i in range(cardsDiscarded):
				p.hand.discardIndex(i)
				
			for i in range(cardsDiscarded):
				p.hand.drawCard()
			break
	
func genDescription() -> String:
	return .genDescription() + "When this creature is played, discard your hand and then draw that many cards. Removes this ability"
