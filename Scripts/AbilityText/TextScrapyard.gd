extends Ability

class_name TextScrapyard

func _init(card : Card).("Graveyard", card, Color.darkgray, false, Vector2(0, 0)):
	pass

func genDescription(subCount = 0) -> String:
	return .genDescription() + "Whenever a card is, milled, discarded, or dies, it is added to your graveyard."
