extends Ability

class_name AbilityRecurrent

func _init(card : Card).("Recurrent", card, Color.brown, false, Vector2(32, 64)):
	pass

func onStartOfTurn():
	if ListOfCards.isInZone(card, CardSlot.ZONES.GRAVE_CARD) and NodeLoc.getBoard().players[NodeLoc.getBoard().activePlayer].UUID == card.playerID:
		addToStack("onEffect", [count])

func onEffect(params):
	var board = NodeLoc.getBoard()
	for p in board.players:
		if p.UUID == card.playerID:
			var g = board.graveCards[p.UUID]
			for i in range(g.size()):
				if g[i] == card:
					board.removeCardFromGrave(p.UUID, i)
					p.hand.addCardToHand([card, true, true])
					return

func genDescription(subCount = 0) -> String:
	return .genDescription() + "At the start of your turn, return this creature from the " + str(TextScrapyard.new(null)) + " to your hand"
