extends Ability

class_name AbilityBounce

func _init(card : Card).("Bounce", card, Color.blue, false, Vector2(0, 0)):
	pass

func onEndOfTurn():
	if NodeLoc.getBoard().isOnBoard(card):
		addToStack("onEffect", [card, card.cardNode.slot])

static func onEffect(params : Array):
	var board = NodeLoc.getBoard()
	for p in board.players:
		if p.UUID == params[1].playerID:
			p.hand.addCardToHand([params[0], true, true])
			if is_instance_valid(params[1].cardNode):
				params[1].cardNode.card.onLeave()
				for c in board.getAllCards():
					if c != params[1].cardNode.card:
						c.onOtherLeave(params[1])
				
				params[1].cardNode.queue_free()
				params[1].cardNode = null
			break

func genDescription(subCount = 0) -> String:
	return .genDescription() + "At the end of the turn, return this card to your hand"
