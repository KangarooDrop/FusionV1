extends AbilityETB

class_name AbilityReignite

func _init(card : Card).("Reignite", card, Color.red, false, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onEffect", [card.playerID])

static func onEffect(params : Array):
	for p in NodeLoc.getBoard().players:
		if p.UUID == params[0]:
			var cardsDiscarded = p.hand.nodes.size()
			for i in range(cardsDiscarded):
				p.hand.discardIndex(i)
				
			for i in range(cardsDiscarded):
				p.hand.drawCard()
			break
	
func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creature is played, discard your hand and then draw that many cards"
