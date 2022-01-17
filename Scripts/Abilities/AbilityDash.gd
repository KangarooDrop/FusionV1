extends Ability

class_name AbilityDash

func _init(card : Card).("Dash", "This creature can attack the turn it is played", card):
	pass

func onEnter(board):
	.onEnter(board)
	card.hasAttacked = false
