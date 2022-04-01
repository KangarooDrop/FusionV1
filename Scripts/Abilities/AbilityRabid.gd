extends Ability

class_name AbilityRabid

func _init(card : Card).("Rabid", card, Color.brown, false, Vector2(16, 48)):
	pass

func onOtherEnter(slot):
	if NodeLoc.getBoard().isOnBoard(card):
		addToStack("onEffect", [card, slot], true, true)

func onEffect(params):
	if is_instance_valid(params[1].cardNode) and params[0].cantAttackSources.size() == 0:
		card.cardNode.attack([params[1]])

func checkWaiting() -> bool:
	var board = NodeLoc.getBoard()
	for c in board.getAllCards():
		if c.cardNode.attacking:
			return false
	return true

func genDescription() -> String:
	return .genDescription() + "When another creature is played, this creature automatically attacks it"
