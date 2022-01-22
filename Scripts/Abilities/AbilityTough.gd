extends Ability

class_name AbilityTough

func _init(card : Card).("Tough", "This creature gains +1/+1 when attacked", card, Color.darkgray, true):
	pass

func onBeingAttacked(attacker, board):
	.onBeingAttacked(attacker, board)
	card.power += count
	card.toughness += count

func combine(abl : Ability):
	.combine(abl)
	desc = "This creature gains +" + str(count) + "/+" + str(count) + " when attacked"
