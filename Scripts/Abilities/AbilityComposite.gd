extends Ability

class_name AbilityComposite

func _init(card : Card).("Composite", card, Color.gray, true, Vector2(0, 80)):
	myVars["buffsApplied"] = 0

func onHoverEnter(slot):
	card.power -= myVars.buffsApplied * myVars.count
	myVars.buffsApplied = 0
	for s in NodeLoc.getBoard().creatures[slot.playerID]:
		if is_instance_valid(s.cardNode) and s != slot:
			card.power += myVars.count
			myVars.buffsApplied += 1

func onHoverExit(slot):
	onRemove(self)

func onEnter(card):
	onEffect()

func onEnterFromFusion(card):
	onEffect()

func onLeave():
	onRemove(self)

func onOtherEnter(slot):
	if NodeLoc.getBoard().isOnBoard(self.card):
		onEffect()

func onOtherEnterFromFusion(slot):
	if NodeLoc.getBoard().isOnBoard(self.card):
		onEffect()
	
func onOtherLeave(slot):
	if NodeLoc.getBoard().isOnBoard(self.card):
		onEffect()

func onEffect():
	card.power -= myVars.buffsApplied * myVars.count
	myVars.buffsApplied = 0
	
	for s in NodeLoc.getBoard().creatures[card.playerID]:
		if is_instance_valid(s.cardNode) and (is_instance_valid(card.cardNode.slot) and s != card.cardNode.slot) and s.cardNode.card.toughness > 0 and not s.cardNode.card.isDying:
			card.power += myVars.count
			myVars.buffsApplied += 1

func onRemove(ability):
	if ability == self:
		card.power -= myVars.buffsApplied * myVars.count
		myVars.buffsApplied = 0
	
func combine(abl : Ability):
	.combine(abl)
	abl.myVars.buffsApplied += myVars.buffsApplied

func genDescription(subCount = 0) -> String:
	return .genDescription() + "Gains +" + str(myVars.count) + " power for each other creature its controller has"
