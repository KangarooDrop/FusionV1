extends Ability

class_name AbilityDash

func _init(card : Card).("Dash", card, Color.red, false, Vector2(0, 0)):
	card.playedThisTurn = false

func onEnter(slot):
	.onEnter(slot)
	card.playedThisTurn = false

func onEnterFromFusion(slot):
	.onEnterFromFusion(slot)
	card.playedThisTurn = false

func genDescription(subCount = 0) -> String:
	return .genDescription() + "This creature can attack the turn it is played"
