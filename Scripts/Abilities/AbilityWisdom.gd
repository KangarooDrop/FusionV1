extends AbilityETB

class_name AbilityWisdom

func _init(card : Card).("Wisedom", card, Color.blue, true, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onEffect", [card.playerID, count - timesApplied])
			
static func onEffect(params : Array):
	for p in NodeLoc.getBoard().players:
		if p.UUID == params[0]:
			for i in range(params[1]):
				p.hand.drawCard()
			break

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creature is played, its controller draws " + str(count - subCount) + (" cards" if count - subCount > 1 else " card")
