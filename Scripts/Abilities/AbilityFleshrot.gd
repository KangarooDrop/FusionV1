extends Ability

class_name AbilityFleshrot

func _init(card : Card).("Fleshrot", card, Color.darkgray, false, Vector2(0, 32)):
	pass
	
func onKilledBy(slot):
	.onKilledBy(slot)
	
	addToStack("onEffect", [slot.cardNode.card])

static func onEffect(params):
	params[0].toughness = -INF

func genDescription() -> String:
	return .genDescription() + "When this creature is killed in combat, the other creature dies as well"
