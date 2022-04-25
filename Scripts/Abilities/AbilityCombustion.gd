extends Ability

class_name AbilityCombustion

func _init(card : Card).("Combustion", card, Color.red, false, Vector2(32, 64)):
	pass

func onDeath():
	addToStack("onEffect", [card, card.cardNode.slot.playerID])

func onEffect(params):
	var board = NodeLoc.getBoard()
	var d = card.power
	for p in board.players:
		if p.UUID == params[1]:
			p.takeDamage(d, params[0])

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creature dies, you take damage equal to its power"
