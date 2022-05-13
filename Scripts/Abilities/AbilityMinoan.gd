extends Ability

class_name AbilityMinoan

func _init(card : Card).("Minoan", card, Color.blue, false, Vector2(16, 80)):
	pass

func onEndOfTurn():
	if NodeLoc.getBoard().isOnBoard(card):
		onEffect()

func onEffect():
	if ListOfCards.isInZone(card, CardSlot.ZONES.CREATURE):
		var board = NodeLoc.getBoard()
		board.cardsMovingCard.append(card)
		board.cardsMovingAbility.append(self)
		board.cardsMovingSlot.append(card.cardNode.slot.getClockwise())
	
func genDescription(subCount = 0) -> String:
	return .genDescription() + "At the end of its controller's turn, this creature moves one space clockwise if nothing blocks its path."
