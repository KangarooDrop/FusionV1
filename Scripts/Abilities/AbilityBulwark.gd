extends Ability

class_name AbilityBulwark

func _init(card : Card).("Bulwark", "Deals damage when attacked equal to the damage taken", card, Color.darkgray, false):
	pass
	
func onBeingAttacked(attacker, board):
	if is_instance_valid(attacker.cardNode):
		attacker.cardNode.card.toughness -= attacker.cardNode.card.power
