extends Ability

class_name AbilitySwarm

var buffsApplied = 0

func _init(card : Card).("Sworm", card, Color.brown, true, Vector2(16, 48)):
	pass

func onHoverEnter(slot):
	onEffect()

func onHoverExit(slot):
	onRemove(self)

func onEnter(slot):
	if NodeLoc.getBoard().isOnBoard(card):
		onEffect()

func onEnterFromFusion(slot):
	if NodeLoc.getBoard().isOnBoard(card):
		onEffect()

func onOtherEnter(slot):
	if NodeLoc.getBoard().isOnBoard(card):
		onEffect()

func onOtherEnterFromFusion(slot):
	if NodeLoc.getBoard().isOnBoard(card):
		onEffect()

func onOtherLeave(slot):
	if NodeLoc.getBoard().isOnBoard(card):
		onEffect()

func onEffect():
	var buffsNew = 0
	var board = NodeLoc.getBoard()
	
	for p in board.players:
		for s in board.creatures[p.UUID]:
			if is_instance_valid(s.cardNode) and ListOfCards.hasAbility(s.cardNode.card, get_script()) and s.cardNode.card != card:
				buffsNew += 1
	
	self.card.power += (buffsNew - buffsApplied) * count
	self.card.toughness += (buffsNew - buffsApplied) * count
	self.card.maxToughness += (buffsNew - buffsApplied) * count
	buffsApplied = buffsNew
	
func onRemove(ability):
	if ability == self:
		self.card.power -= buffsApplied * count
		self.card.toughness -= buffsApplied * count
		self.card.maxToughness -= buffsApplied * count
		buffsApplied = 0

func clone(card : Card) -> Ability:
	var abl = .clone(card)
	abl.buffsApplied = buffsApplied
	return abl

func combine(abl : Ability):
	.combine(abl)
	abl.buffsApplied += buffsApplied

func genDescription() -> String:
	return .genDescription() + "This creature gets +" + str(count) + "/+" + str(count) + " for each other creature with " + name
