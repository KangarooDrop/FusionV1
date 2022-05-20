extends Ability

class_name AbilitySwarm

func _init(card : Card).("Swarm", card, Color.brown, true, Vector2(16, 48)):
	myVars["buffsApplied"] = 0

func onHoverEnter(slot):
	onEffect()
	if not is_instance_valid(slot.cardNode) or not ListOfCards.hasAbility(slot.cardNode.card, get_script()):
		self.card.power += myVars.count
		self.card.toughness += myVars.count
		self.card.maxToughness += myVars.count

func onHoverExit(slot):
	onRemove(self)
	if not is_instance_valid(slot.cardNode) or not ListOfCards.hasAbility(slot.cardNode.card, get_script()):
		self.card.power -= myVars.count
		self.card.toughness -= myVars.count
		self.card.maxToughness -= myVars.count

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
		if is_instance_valid(slot.cardNode) and ListOfCards.hasAbility(slot.cardNode.card, get_script()):
			onEffect()

func onEffect():
	self.card.power -= myVars.buffsApplied
	self.card.toughness -= myVars.buffsApplied
	self.card.maxToughness -= myVars.buffsApplied
	
	myVars.buffsApplied = 0
	var board = NodeLoc.getBoard()
	
	for p in board.players:
		for s in board.creatures[p.UUID]:
			if is_instance_valid(s.cardNode) and ListOfCards.hasAbility(s.cardNode.card, get_script()):
				myVars.buffsApplied += 1
	
	myVars.buffsApplied *= myVars.count
	self.card.power += myVars.buffsApplied
	self.card.toughness += myVars.buffsApplied
	self.card.maxToughness += myVars.buffsApplied
	
func onRemove(ability):
	if ability == self:
		self.card.power -= myVars.buffsApplied
		self.card.toughness -= myVars.buffsApplied
		self.card.maxToughness -= myVars.buffsApplied
		myVars.buffsApplied = 0
		
		var board = NodeLoc.getBoard()
		if board != null:
			for c in board.getAllCards():
				if board.isOnBoard(c):
					for abl in c.abilities.duplicate():
						if abl is get_script():
							abl.onEffect()

func combine(abl : Ability):
	.combine(abl)
	abl.myVars.buffsApplied += myVars.buffsApplied

func genDescription(subCount = 0) -> String:
	return .genDescription() + "This creature gets +" + str(myVars.count) + "/+" + str(myVars.count) + " for each creature with " + name
