extends Ability

class_name AbilityLacerate

func _init(card : Card).("Lacerate", card, Color.purple, false, Vector2(0, 0)):
	pass

func onEnterFromFusion(slot):
	addToStack("onEffect", [card])
	
func onEffect(params):
	params[0].toughness -= INF
	
	for abl in params[0].abilities:
		if abl is get_script():
			params[0].removeAbility(abl)

func genDescription(subCount = 0) -> String:
	return .genDescription() + "On fusion, destroys this creature. Removes this ability"
