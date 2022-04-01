extends Ability

class_name AbilityUpgrade

func _init(card : Card).("Upgrade", card, Color.lightgray, true, Vector2(0, 0)):
	pass

func onEnter(slot):
	.onEnter(slot)
	addToStack("onEffect", [card.playerID, count])
	card.removeAbility(self)
	
func onEnterFromFusion(slot):
	.onEnterFromFusion(slot)
	addToStack("onEffect", [card.playerID, count])
	card.removeAbility(self)
			
static func onEffect(params : Array):
	for p in NodeLoc.getBoard().players:
		if p.UUID == params[0]:
			for cn in p.hand.nodes:
				for abl in cn.card.abilities:
					abl.setCount(abl.count + params[1])
			break

func genDescription() -> String:
	return .genDescription() + "When this creature is played, increase the count of each ability on all cards in your hand by " + str(count) +". Removes this ability"
