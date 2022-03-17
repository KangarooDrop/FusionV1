extends Ability

class_name AbilityDash

func _init(card : Card).("Dash", card, Color.red, false, Vector2(0, 0)):
	pass

func onEnter(board, slot):
	.onEnter(board, slot)
	card.hasAttacked = false

func onEnterFromFusion(board, slot):
	.onEnterFromFusion(board, slot)
	card.hasAttacked = false

func genDescription() -> String:
	return "This creature can attack the turn it is played"
