extends Ability

class_name AbilityTough

func _init(card : Card).("Tough", card, Color.darkgray, true, Vector2(0, 48)):
	pass

func onBeingAttacked(attacker, board):
	.onBeingAttacked(attacker, board)
	card.power += count
	card.toughness += count

func genDescription() -> String:
	return "This creature gains +" + str(count) + "/+" + str(count) + " when attacked"
