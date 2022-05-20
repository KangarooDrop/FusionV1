extends AbilityETB

class_name AbilityWisdom

func _init(card : Card).("Wisedom", card, Color.blue, true, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onEffect", [])
			
func onEffect(params : Array):
	for p in NodeLoc.getBoard().players:
		if p.UUID == card.playerID:
			for i in range(myVars.count - myVars.timesApplied):
				p.hand.drawCard()
			break
	myVars.timesApplied = myVars.count

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creature is played, its controller draws " + str(myVars.count - subCount) + (" cards" if myVars.count - subCount > 1 else " card")
