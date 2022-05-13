extends Ability

class_name AbilityTransform

func _init(card : Card).("Transform", card, Color.darkgray, false, Vector2(0, 0)):
	pass
	
func onFusion():
	var power = card.power
	card.power = card.toughness
	card.toughness = power
	card.maxToughness = power

func genDescription(subCount = 0) -> String:
	return .genDescription() + "On fusion, swap this creature's power and health"
