extends AbilityETB

class_name AbilityUpgrade

func _init(card : Card).("Upgrade", card, Color.lightgray, true, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onEffect", [count - timesApplied])
			
func onEffect(params : Array):
	for p in NodeLoc.getBoard().players:
		if p.UUID == card.playerID:
			for cn in p.hand.nodes:
				for abl in cn.card.abilities:
					abl.setCount(abl.count + params[0])
			break

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creature is played, increase the count of each ability on all cards in its controller's hand by " + str(count - subCount)
