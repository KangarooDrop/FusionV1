extends Ability

class_name AbilityLacerate

func _init(card : Card).("Lacerate", card, Color.purple, false, Vector2(0, 0)):
	pass

func onEnterFromFusion(slot):
	addToStack("onEffect", [])
	
func onEffect(params):
	card.isDying = true

func genDescription(subCount = 0) -> String:
	return .genDescription() + "On fusion, destroys this creature"
