extends AbilityETB

class_name AbilityOvergrowth

func _init(card : Card).("Overgrowth", card, Color.brown, true, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onEffect", [card.playerID, get_script(), count - timesApplied])

static func onEffect(params):
	var board = NodeLoc.getBoard()
	for p in board.players:
		if p.UUID == params[0]:
			for i in range(params[2]):
				var card = p.deck.tutorByAbility(params[1])
				if card != null:
					p.hand.addCardToHand([card, true, true])

func genDescription(subCount = 0) -> String:
	var string
	if count == 1:
		string = "1 card"
	else:
		string = str(count) + " cards"
	return .genDescription() + "When this creature is played, its controller draws " + string +" with " + str(get_script().new(null)) + " from their deck"
