extends AbilityETB

class_name AbilityTransform

func _init(card : Card).("Transform", card, Color.darkgray, false, Vector2(0, 0)):
	pass
	
func onApplied(slot):
	addToStack("onEffect", [])
			
func onEffect(params):
	var power = card.power
	card.power = card.toughness
	card.toughness = power
	card.maxToughness = power

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creature is played, swap its power and health"
