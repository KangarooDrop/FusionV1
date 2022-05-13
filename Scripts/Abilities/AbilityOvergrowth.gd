extends AbilityETB

class_name AbilityOvergrowth

func _init(card : Card).("Overgrowth", card, Color.brown, true, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onEffect", [])

func onEffect(params):
	var board = NodeLoc.getBoard()
	for p in board.players:
		if p.UUID == self.card.playerID:
			for i in range(count - timesApplied):
				var card = p.deck.tutorByAbility(self.get_script())
				if card != null:
					p.hand.addCardToHand([card, false, true])
	timesApplied = count

func genDescription(subCount = 0) -> String:
	var string
	if count == 1:
		string = "1 card"
	else:
		string = str(count) + " cards"
	return .genDescription() + "When this creature is played, its controller draws " + string +" with " + str(get_script().new(null)) + " from their deck"
