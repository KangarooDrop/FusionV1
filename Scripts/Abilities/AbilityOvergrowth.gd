extends AbilityETB

class_name AbilityOvergrowth

func _init(card : Card).("Overgrowth", card, Color.brown, false, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onEffect", [card.playerID, get_script()])

static func onEffect(params):
	var board = NodeLoc.getBoard()
	for p in board.players:
		if p.UUID == params[0]:
			var card = p.deck.tutorByAbility(params[1])
			if card != null:
				p.hand.addCardToHand([card, true, true])

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creature is played, draw another card with " + str(get_script().new(null)) + " from your deck"
