extends Ability

class_name AbilityVenomous

func _init(card : Card).("Venomous", card, Color.brown, true, Vector2(16, 64)):
	myVars["activated"] = false

func onBeforeDamage(attacker, blocker):
	if (attacker == card.cardNode.slot and is_instance_valid(blocker.cardNode)) or (blocker == card.cardNode.slot and is_instance_valid(attacker.cardNode)):
		card.power += myVars.count
		myVars.activated = true

func onAfterDamage(attacker, blocker):
	if myVars.activated:
		myVars.activated = false
		card.power -= myVars.count

func genDescription(subCount = 0) -> String:
	return .genDescription() + "While fighting another creature, this creature has +" + str(myVars.count) + " power"
