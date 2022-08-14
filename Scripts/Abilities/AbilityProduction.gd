extends AbilityETB

class_name AbilityProduction

func _init(card : Card).("Production", card, Color.gray, true, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onEffect", [])

func onEffect(params):
	for i in range(myVars.count - myVars.timesApplied):
		var card = ListOfCards.getCard(5)
		card.abilities[0].myVars.timesApplied = 1
		self.card.addCreatureToBoard(card, null)
	myVars.timesApplied = myVars.count

func genDescription(subCount = 0) -> String:
	var string = "a"
	if myVars.count > 1:
		string = str(myVars.count - subCount)
	return .genDescription() + "When this creature is played, its controller creates " + string +" 1/1 mech with no abilities"
