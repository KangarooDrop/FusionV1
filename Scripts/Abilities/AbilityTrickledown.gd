extends Ability

class_name AbilityTrickledown

var delayed = false

func _init(card : Card).("Trickledown", card, Color.blue, true, Vector2(0, 0)):
	pass

func onDeath():
	delayed = true
	addDelayedAbility()
	delayed = false

func onStartOfTurn():
	if delayed:
		var board = NodeLoc.getBoard()
		if board.players[board.activePlayer].UUID == card.playerID:
			addToStack("onEffect", [])
			card.removeAbility(self)

func onEffect(params):
	var board = NodeLoc.getBoard()
	board.addCardsPerTurn(count)

func clone(card) -> Ability:
	var abl = .clone(card)
	abl.delayed = delayed
	return abl

func genDescription(subCount = 0) -> String:
	return .genDescription() + "After this creature dies, gain " + str(count) +" energy on your next turn"
