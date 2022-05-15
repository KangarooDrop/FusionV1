extends Ability

class_name AbilitySwarm

var buffsApplied = 0

func _init(card : Card).("Swarm", card, Color.brown, true, Vector2(16, 48)):
	pass

func onHoverEnter(slot):
	onEffect()
	if not is_instance_valid(slot.cardNode) or not ListOfCards.hasAbility(slot.cardNode.card, get_script()):
		self.card.power += count
		self.card.toughness += count
		self.card.maxToughness += count

func onHoverExit(slot):
	onRemove(self)
	if not is_instance_valid(slot.cardNode) or not ListOfCards.hasAbility(slot.cardNode.card, get_script()):
		self.card.power -= count
		self.card.toughness -= count
		self.card.maxToughness -= count

func onEnter(slot):
	if NodeLoc.getBoard().isOnBoard(card):
		onEffect()

func onEnterFromFusion(slot):
	if NodeLoc.getBoard().isOnBoard(card):
		onEffect()

func onOtherEnter(slot):
	if NodeLoc.getBoard().isOnBoard(card):
		if is_instance_valid(slot.cardNode) and ListOfCards.hasAbility(slot.cardNode.card, get_script()):
			onEffect()

func onOtherEnterFromFusion(slot):
	if NodeLoc.getBoard().isOnBoard(card):
		if is_instance_valid(slot.cardNode) and ListOfCards.hasAbility(slot.cardNode.card, get_script()):
			onEffect()

func onOtherLeave(slot):
	if NodeLoc.getBoard().isOnBoard(card):
		if is_instance_valid(slot.cardNode):
			print("HERE! ", slot.cardNode.card, "  ", ListOfCards.hasAbility(slot.cardNode.card, get_script()))
		else:
			print("NOT HERE!")
		if is_instance_valid(slot.cardNode) and ListOfCards.hasAbility(slot.cardNode.card, get_script()):
			onEffect()

func onEffect():
	self.card.power -= buffsApplied
	self.card.toughness -= buffsApplied
	self.card.maxToughness -= buffsApplied
	
	buffsApplied = 0
	var board = NodeLoc.getBoard()
	
	for p in board.players:
		for s in board.creatures[p.UUID]:
			if is_instance_valid(s.cardNode) and ListOfCards.hasAbility(s.cardNode.card, get_script()):
				buffsApplied += 1
	
	buffsApplied *= count
	self.card.power += buffsApplied
	self.card.toughness += buffsApplied
	self.card.maxToughness += buffsApplied
	
func onRemove(ability):
	if ability == self:
		self.card.power -= buffsApplied
		self.card.toughness -= buffsApplied
		self.card.maxToughness -= buffsApplied
		buffsApplied = 0
		
		var board = NodeLoc.getBoard()
		if board != null:
			for c in board.getAllCards():
				if board.isOnBoard(c):
					for abl in c.abilities.duplicate():
						if abl is get_script():
							abl.onEffect()

func clone(card : Card) -> Ability:
	var abl = .clone(card)
	abl.buffsApplied = buffsApplied
	return abl

func combine(abl : Ability):
	.combine(abl)
	abl.buffsApplied += buffsApplied

func genDescription(subCount = 0) -> String:
	return .genDescription() + "This creature gets +" + str(count) + "/+" + str(count) + " for each creature with " + name
