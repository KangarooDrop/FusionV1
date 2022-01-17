extends Ability

class_name AbilityTough

func _init(card : Card).("Tough", "This creature gains +1/+1 when attacked", card):
	pass

func onBeingAttacked(attacker, board):
	.onBeingAttacked(attacker, board)
	card.power += 1
	card.toughness += 1
