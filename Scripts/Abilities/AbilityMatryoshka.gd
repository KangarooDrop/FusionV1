extends Ability

class_name AbilityMatryoshka

func _init(card : Card).("Matryoshka", card, Color.darkgray, true, Vector2(32, 96)):
	pass

func onDeath():
	.onDeath()
	addToStack("onEffect", [count])

func onEffect(params):
	var hand = null
	for p in NodeLoc.getBoard().players:
		if p.UUID == card.playerID:
			for i in range(params[0]):
				p.hand.addCardToHand([ListOfCards.getCard(57), true, true])
			break

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creature dies, add " + str(count) + " " + str(TextCard.new(ListOfCards.getCard(57))) +" to its controller's hand"
