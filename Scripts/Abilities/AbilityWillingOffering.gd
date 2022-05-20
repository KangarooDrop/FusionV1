extends Ability

class_name AbilityWillingOffering

func _init(card).("Willing Offering", card, Color.darkgray, false, Vector2(16, 48)):
	myVars["buffsApplied_P"] = 0
	myVars["buffsApplied_T"] = 0

func onOtherEnter(slot):
	if NodeLoc.getBoard().isOnBoard(card):
		if slot.playerID == card.playerID:
			addToStack("onEffect", [slot.cardNode.card])

func onEffect(params):
	if NodeLoc.getBoard().isOnBoard(card) and NodeLoc.getBoard().isOnBoard(params[0]):
		if params[0].power > 0:
			card.power += params[0].power
			myVars.buffsApplied_P += params[0].power
		if params[0].toughness > 0:
			card.toughness += params[0].toughness
			card.maxToughness += params[0].maxToughness
			myVars.buffsApplied_T += params[0].toughness
		
		params[0].isDying = true

func combine(abl):
	.combine(abl)
	abl.myVars.buffsApplied_P += myVars.buffsApplied_P
	abl.myVars.buffsApplied_T += myVars.buffsApplied_T

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When a creature is put onto the board under your control, destroy that creature and get its power and toughness"
