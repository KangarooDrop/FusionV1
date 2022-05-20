extends Ability

class_name AbilityMatryoshka

func _init(card : Card).("Matryoshka", card, Color.darkgray, true, Vector2(32, 96)):
	pass

func onDeath():
	.onDeath()
	addToStack("onEffect", [])

func onEffect(params):
	var hand = null
	for p in NodeLoc.getBoard().players:
		if p.UUID == card.playerID:
			for i in range(myVars.count):
				p.hand.addCardToHand([ListOfCards.getCard(1028), true, true])
			break

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creature dies, add " + str(myVars.count) + " " + str(TextCard.new(ListOfCards.getCard(1028))) +" to its controller's hand"
