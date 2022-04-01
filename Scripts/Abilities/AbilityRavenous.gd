extends Ability

class_name AbilityRavenous

func _init(card : Card).("Ravenous", card, Color.brown, false,Vector2(0, 64)):
	pass

func onKill(slot):
	card.hasAttacked = false

func genDescription() -> String:
	return .genDescription() + "When this creature kills another creature, it can attack again"
