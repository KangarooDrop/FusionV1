extends Ability

class_name AbilityWillingOffering

var buffsAppliedVec = Vector2()

func _init(card).("Willing Offering", card, Color.darkgray, false, Vector2(16, 48)):
	pass

func onOtherEnter(slot):
	if NodeLoc.getBoard().isOnBoard(card):
		if slot.playerID == card.playerID:
			addToStack("onEffect", [self.card, slot.cardNode.card])

func onRemove(ability):
	if ability == self:
		card.power -= buffsAppliedVec.x
		card.toughness -= buffsAppliedVec.y
		card.maxToughness -= buffsAppliedVec.y

func onEffect(params):
	if params[1].power > 0:
		params[0].power += params[1].power
		buffsAppliedVec.x += params[1].power
	if params[1].toughness > 0:
		params[0].toughness += params[1].toughness
		params[0].maxToughness += params[1].maxToughness
		buffsAppliedVec.y += params[1].toughness
	params[1].toughness = -INF

func clone(card):
	var abl = .clone(card)
	abl.buffsAppliedVec = buffsAppliedVec
	return abl

func combine(abl):
	.combine(abl)
	abl.buffsAppliedVec += buffsAppliedVec

func genDescription() -> String:
	return .genDescription() + "When a creature is put onto the board under your control, destroy that creature and get its power and toughness"
