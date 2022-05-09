extends AbilityETB

class_name AbilityFledge

func _init(card : Card).("Fledge", card, Color.gold, false, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onEffect", [])

func onEffect(params):
	if ListOfCards.isInZone(card, CardSlot.ZONES.CREATURE):
		var slots = card.cardNode.slot.getNeighbors()
		for s in slots:
			var card = ListOfCards.getCard(84)
			self.card.addCreatureToBoard(card, s)
	
	timesApplied = count

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creature is played, create a 0/0 ooze on either side of it"
