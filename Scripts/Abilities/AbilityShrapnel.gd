extends Ability

class_name AbilityShrapnel

func _init(card : Card).("Shrapnel", card, Color.gray, false,Vector2(0, 64)):
	pass

func onKill(slot):
	addToStack("onEffect", [slot])

func onEffect(params):
	card.addCreatureToBoard(ListOfCards.getCard(95), params[0])

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creature kills another creature, leave behind a " + str(TextCard.new(ListOfCards.getCard(95))) + " where that creature was"
