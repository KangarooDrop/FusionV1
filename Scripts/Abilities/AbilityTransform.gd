extends AbilityETB

class_name AbilityTransform

func _init(card : Card).("Transform", card, Color.darkgray, false, Vector2(0, 0)):
	pass
	
func onApplied(slot):
	addToStack("onEffect", [card])
			
static func onEffect(params):
	var power = params[0].power
	params[0].power = params[0].toughness
	params[0].toughness = power

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creature is played, swap its power and health"
