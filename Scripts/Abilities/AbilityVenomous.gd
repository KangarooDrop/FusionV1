extends Ability

class_name AbilityVenomous

var activated = false

func _init(card : Card).("Venomous", card, Color.brown, true, Vector2(16, 64)):
	pass

func onBeforeDamage(attacker, blocker):
	if (attacker == card.cardNode.slot and is_instance_valid(blocker.cardNode)) or (blocker == card.cardNode.slot and is_instance_valid(attacker.cardNode)):
		card.power += count
		activated = true

func onAfterDamage(attacker, blocker):
	if activated:
		activated = false
		card.power -= count

func genDescription() -> String:
	return .genDescription() + "While attacking another creature, this creature has +" + str(count) + " power"
