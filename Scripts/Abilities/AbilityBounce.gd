extends Ability

class_name AbilityBounce

func _init(card : Card).("Bounce", card, Color.purple, false, Vector2(0, 0)):
	pass

func onEndOfTurn():
	if NodeLoc.getBoard().isOnBoard(card):
		addToStack("onEffect", [card])

static func onEffect(params : Array):
	var board = NodeLoc.getBoard()
	for p in board.players:
		if p.UUID == params[0].playerID:
			if is_instance_valid(params[0].cardNode):
				params[0].onLeave()
				for c in board.getAllCards():
					if c != params[0]:
						c.onOtherLeave(params[0].cardNode.slot)
				
				params[0].cardNode.queue_free()
				params[0].cardNode = null
			
			p.hand.addCardToHand([params[0].clone(true), true, true])
			break

func genDescription(subCount = 0) -> String:
	return .genDescription() + "At the end of the turn, return this card to its controller's hand"
