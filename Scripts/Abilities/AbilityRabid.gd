extends Ability

class_name AbilityRabid

func _init(card : Card).("Rabid", card, Color.brown, false, Vector2(16, 48)):
	pass

func onOtherEnter(slot):
	if NodeLoc.getBoard().isOnBoard(card):
		addToStack("onEffect", [slot], true, true)

func onEffect(params):
	if ListOfCards.isInZone(card, CardSlot.ZONES.CREATURE) and card.canAttack():
		card.cardNode.attack([params[0]])

func checkWaiting() -> bool:
	var board = NodeLoc.getBoard()
	for c in board.getAllCards():
		if is_instance_valid(c.cardNode) and c.cardNode.attacking:
			return false
	return true

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When another creature is played, this creature automatically attacks it if able"
