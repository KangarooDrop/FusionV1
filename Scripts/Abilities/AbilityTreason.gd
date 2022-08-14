extends AbilityETB

class_name AbilityTreason

func _init(card : Card).("Treason", card, Color.red, false, Vector2(0, 0)):
	myVars["returned"] = false

func onApplied(slot):
	addToStack("onStealEffect", [false])

func onEndOfTurn():
	if NodeLoc.getBoard().isOnBoard(card) and not myVars.returned:
		addToStack("onStealEffect", [true])

func onStealEffect(params):
	if not ListOfCards.isInZone(card, CardSlot.ZONES.CREATURE):
		myVars.timesApplied = 0
		return
		
	myVars.timesApplied = myVars.count
	
	var board = NodeLoc.getBoard()
	for p in board.players:
		if p.UUID != card.playerID:
			var swapped = false
			for slot in board.creatures[p.UUID]:
				if not is_instance_valid(slot.cardNode):
					swapSlot(card.cardNode, slot)
					swapped = true
					break
			
			myVars.returned = params[0] or not swapped
			
			
			if not params[0]:
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
	return .genDescription() + "When this creature is played, its opponent gains control of it until the end of the turn. It may attack this turn"
