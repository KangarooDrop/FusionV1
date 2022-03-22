extends Ability

class_name AbilityTaunt

var active : bool = true

func _init(card : Card).("Taunt", card, Color.darkgray, false, Vector2(0, 0)):
	pass

func onStartOfTurn(board):
	if board.isOnBoard(card):
		active = true

func onBeingAttacked(board, attacker):
	active = false

func genDescription() -> String:
	return "Once per turn, this creature must be the target of enemy attacks"

func clone(card : Card) -> Ability:
	var abl = .clone(card)
	abl.active = active
	return abl
