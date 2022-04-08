extends Ability

class_name AbilityComposite

var buffsApplied = 0

func _init(card : Card).("Composite", card, Color.gray, true, Vector2(0, 80)):
	pass

func onHoverEnter(slot):
	card.power -= buffsApplied * count
	buffsApplied = 0
	for s in NodeLoc.getBoard().creatures[slot.playerID]:
		if is_instance_valid(s.cardNode) and s != slot:
			card.power += count
			buffsApplied += 1

func onHoverExit(slot):
	onRemove(self)

func onEnter(card):
	onEffect()

func onEnterFromFusion(card):
	onEffect()

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
	card.power -= buffsApplied * count
	buffsApplied = 0
	
	for s in NodeLoc.getBoard().creatures[card.playerID]:
		if is_instance_valid(s.cardNode) and (is_instance_valid(card.cardNode.slot) and s != card.cardNode.slot) and s.cardNode.card.toughness > 0:
			card.power += count
			buffsApplied += 1

func onRemove(ability):
	if ability == self:
		card.power -= buffsApplied * count
		buffsApplied = 0

func clone(card : Card) -> Ability:
	var abl = .clone(card)
	abl.buffsApplied = buffsApplied
	return abl
	
func combine(abl : Ability):
	.combine(abl)
	abl.buffsApplied += buffsApplied

func genDescription(subCount = 0) -> String:
	return .genDescription() + "Gains +" + str(count) + " power for each other creature you control"
