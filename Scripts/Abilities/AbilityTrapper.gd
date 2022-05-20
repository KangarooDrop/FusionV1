extends Ability

class_name AbilityTrapper

func _init(card : Card).("Trapper", card, Color.gray, false, Vector2(0, 64)):
	pass

func onKill(slot):
	addToStack("onEffect", [slot])

func onEffect(params):
	var cardNew = ListOfCards.getCard(1065)
	card.addCreatureToBoard(cardNew, params[0])
	var pid
	for p in NodeLoc.getBoard().players:
		if p.UUID != card.playerID:
			pid = p.UUID
			break
	cardNew.playerID = pid

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creature kills another creature, leave behind a " + str(TextCard.new(ListOfCards.getCard(1065))) + " where that creature was"
