extends AbilityETB

class_name AbilityTreason

var returned = false

func _init(card : Card).("Treason", card, Color.red, false, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onStealEffect", [self, false])

func onEndOfTurn():
	if NodeLoc.getBoard().isOnBoard(card) and not returned:
		addToStack("onStealEffect", [self, true])

func onStealEffect(params):
	var board = NodeLoc.getBoard()
	for p in board.players:
		if p.UUID != card.playerID:
			for slot in board.creatures[p.UUID]:
				if not is_instance_valid(slot.cardNode):
					swapSlot(card.cardNode, slot)
					params[0].returned = params[1]
					
					if not params[1]:
						card.hasAttacked = false
						card.playedThisTurn = false
					
					return

static func swapSlot(cardNode, newSlot):
	cardNode.slot.cardNode = null
	cardNode.slot = newSlot
	newSlot.cardNode = cardNode
	cardNode.global_position = newSlot.global_position
	cardNode.playerID = newSlot.playerID
	cardNode.card.playerID = newSlot.playerID

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creature is played, its controller's opponent gains control of it until the end of the turn and it may attack this turn"
