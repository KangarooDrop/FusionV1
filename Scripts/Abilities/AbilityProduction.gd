extends AbilityETB

class_name AbilityProduction

func _init(card : Card).("Production", card, Color.gray, true, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onEffect", [count - timesApplied])

func onEffect(params):
	for i in range(params[0]):
		var card = ListOfCards.getCard(5)
		card.abilities[0].timesApplied = 1
		self.card.addCreatureToBoard(card, null)

func genDescription(subCount = 0) -> String:
	var string = "a"
	if count > 1:
		string = str(count - subCount)
	return .genDescription() + "When this creature is played, its controller creates " + string +" 1/1 mech with no abilities"
