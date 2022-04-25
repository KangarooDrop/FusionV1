extends AbilityETB

class_name AbilityStampede

func _init(card : Card).("Stampede", card, Color.brown, false, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onEffect", [card.playerID], true, true)

static func onEffect(params):
	var board = NodeLoc.getBoard()
	for slot in board.creatures[params[0]]:
		if is_instance_valid(slot.cardNode):
			slot.cardNode.attack([slot.getAcross()])

func checkWaiting() -> bool:
	var board = NodeLoc.getBoard()
	for c in board.getAllCards():
		if is_instance_valid(c.cardNode) and c.cardNode.attacking:
			return false
	return true

func genDescription(subCount = 0) -> String:
	var strCount = str(count - subCount)
	return .genDescription() + "When this creature is played, each creatures you control attacks the slot across from itself"
