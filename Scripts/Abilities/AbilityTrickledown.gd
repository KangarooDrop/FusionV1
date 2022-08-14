extends Ability

class_name AbilityTrickledown

func _init(card : Card).("Trickledown", card, Color.blue, true, Vector2(0, 0)):
	myVars["delayed"] = false

func onDeath():
	myVars.delayed = true
	addDelayedAbility()
	myVars.delayed = false

func onStartOfTurn():
	if myVars.delayed:
		var board = NodeLoc.getBoard()
		if board.players[board.activePlayer].UUID == card.playerID:
			addToStack("onEffect", [])
			card.removeAbility(self)

func onEffect(params):
	var board = NodeLoc.getBoard()
	board.addCardsPerTurn(myVars.count)

func genDescription(subCount = 0) -> String:
	return .genDescription() + "After this creature dies, gain " + str(myVars.count) +" energy on your next turn"
