extends Ability

class_name AbilityTaunt

func _init(card : Card).("Taunt", card, Color.darkgray, false, Vector2(0, 0)):
	myVars["active"] = true

func onStartOfTurn():
	if NodeLoc.getBoard().isOnBoard(card):
		myVars.active = true

func onAfterDamage(attacker, blocker):
	myVars.active = false

func genDescription(subCount = 0) -> String:
	return .genDescription() + "Once per turn, this creature must be the target of enemy attacks"
