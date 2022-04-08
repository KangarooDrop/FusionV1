extends Ability

class_name TextScrapyard

func _init(card : Card).("Scrapyard", card, Color.darkgray, false, Vector2(0, 0)):
	pass

func genDescription(subCount = 0) -> String:
	return .genDescription() + "Whenever a card is played, milled, or discarded, it is added to your scrapyard."
