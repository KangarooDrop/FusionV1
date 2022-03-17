extends Ability

class_name AbilityBulwark

func _init(card : Card).("Bulwark", card, Color.darkgray, false, Vector2(32, 48)):
	pass
	
func onBeingAttacked(attacker, board):
	if is_instance_valid(attacker.cardNode):
		attacker.cardNode.card.toughness -= attacker.cardNode.card.power

func genDescription() -> String:
	return "Deals damage when attacked equal to the damage taken"
