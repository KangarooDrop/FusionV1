extends Ability

class_name AbilityInfested

func _init(card : Card).("Infested", card, Color.darkgray, true, Vector2(32, 96)):
	pass

func onDeath():
	.onDeath()
	addToStack("onEffect", [])

func onEffect(params):
	for i in range(myVars.count):
		var card = ListOfCards.getCard(6)
		card.abilities.clear()
		card.power = 1
		card.toughness = 1
		self.card.addCreatureToBoard(card, null)

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creature dies, creates " + str(myVars.count) + " 1/1 Necro with no abilities"
