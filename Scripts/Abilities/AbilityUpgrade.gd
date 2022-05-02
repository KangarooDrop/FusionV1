extends AbilityETB

class_name AbilityUpgrade

func _init(card : Card).("Upgrade", card, Color.lightgray, true, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onEffect", [card.playerID, count - timesApplied])
			
static func onEffect(params : Array):
	for p in NodeLoc.getBoard().players:
		if p.UUID == params[0]:
			for cn in p.hand.nodes:
				for abl in cn.card.abilities:
					abl.setCount(abl.count + params[1])
			break

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creature is played, increase the count of each ability on all cards in its controller's hand by " + str(count - subCount)
