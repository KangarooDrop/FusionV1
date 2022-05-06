extends Ability

class_name AbilitySecondStrike

var activated = false

func _init(card : Card).("Second Strike", card, Color.brown, false, Vector2(16, 48)):
	pass

func onStartOfTurn():
	activated = false

func onAfterCombat(attacker, blockers):
	if NodeLoc.getBoard().isOnBoard(card):
		if attacker == card.cardNode.slot:
			if not activated:
				addToStack("onEffect", [blockers], true, true)
			activated = not activated

func onEffect(params):
	card.cardNode.attack(params[0])

func checkWaiting() -> bool:
	var board = NodeLoc.getBoard()
	for c in board.getAllCards():
		if is_instance_valid(c.cardNode) and c.cardNode.attacking:
			return false
	return true
	
func clone(card : Card) -> Ability:
	var abl = .clone(card)
	abl.activated = activated
	return abl

func combine(abl : Ability):
	.combine(abl)
	abl.activated = activated or abl.activated

func genDescription(subCount = 0) -> String:
	return .genDescription() + "After this creature attacks for the first time, it attacks again"
