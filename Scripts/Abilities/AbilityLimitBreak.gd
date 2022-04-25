extends Ability

class_name AbilityLimitBreak

func _init(card : Card).("Limit Break", card, Color.purple, false, Vector2(0, 0)):
	pass

func onAdjustCost(card, cost) -> int:
	if card == self.card:
		return -99
	return 0

func genDescription(subCount = 0) -> String:
	return .genDescription() + "This card is free to play"
