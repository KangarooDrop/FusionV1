extends Ability

class_name AbilityDash

func _init(card : Card).("Dash", card, Color.red, false, Vector2(0, 0)):
	pass

func onEnter(slot):
	.onEnter(slot)
	card.playedThisTurn = false

func onEnterFromFusion(slot):
	.onEnterFromFusion(slot)
	card.playedThisTurn = false

func genDescription() -> String:
	return .genDescription() + "This creature can attack the turn it is played"
