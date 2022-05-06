extends Ability

class_name AbilityBounce

func _init(card : Card).("Bounce", card, Color.purple, false, Vector2(0, 0)):
	pass

func onEndOfTurn():
	if NodeLoc.getBoard().isOnBoard(card):
		addToStack("onEffect", [])

func onEffect(params : Array):
	var board = NodeLoc.getBoard()
	for p in board.players:
		if p.UUID == card.playerID:
			if is_instance_valid(card.cardNode):
				card.onLeave()
				for c in board.getAllCards():
					if c != card:
						c.onOtherLeave(card.cardNode.slot)
				
				card.cardNode.queue_free()
				card.cardNode = null
			
			p.hand.addCardToHand([card.clone(true), true, true])
			break

func genDescription(subCount = 0) -> String:
	return .genDescription() + "At the end of the turn, return this card to its controller's hand"
