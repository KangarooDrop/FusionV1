extends Ability

class_name AbilityTaunt

func _init(card : Card).("Taunt", "This creature must be the target of enemy attacks", card, Color.darkgray, false, Vector2(0, 0)):
	pass

func onEndOfTurn(board):
	card.heal(1)
