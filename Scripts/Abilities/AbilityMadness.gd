extends Ability

class_name AbilityMadness

func _init(card : Card).("Madness", card, Color.blue, true, Vector2(0, 0)):
	myVars["buffsApplied"] = 0

func onHoverEnter(slot):
	var pid = slot.playerID
	for player in NodeLoc.getBoard().players:
		if player.UUID == pid:
			var num = player.deck.deckSize - player.deck.cards.size()
			var dif = num * myVars.count - myVars.buffsApplied
			card.power += dif
			card.toughness += dif
			card.maxToughness += dif
			myVars.buffsApplied += dif
			
			break

func onHoverExit(slot):
	var pid = slot.playerID
	for player in NodeLoc.getBoard().players:
		if player.UUID == pid:
			var dif = myVars.buffsApplied
			card.power -= dif
			card.toughness -= dif
			card.maxToughness -= dif
			myVars.buffsApplied -= dif
			break

func onDraw(card):
	if NodeLoc.getBoard().isOnBoard(self.card):
		onEffect()

func onEnter(slot):
	onEffect()
	
func onEnterFromFusion(slot):
	onEffect()
	
func onMill(card):
	if NodeLoc.getBoard().isOnBoard(self.card):
		onEffect()

func onEffect():
	var pid = card.playerID
	for player in NodeLoc.getBoard().players:
		if player.UUID == pid:
			var num = player.deck.deckSize - player.deck.cards.size()
			var dif = num * myVars.count - myVars.buffsApplied
			card.power += dif
			card.toughness += dif
			card.maxToughness += dif
			myVars.buffsApplied += dif
			
			break

func onRemove(ability):
	var board = NodeLoc.getBoard()
	if board is BoardMP:
		if ability == self:
			var pid = card.playerID
			for player in NodeLoc.getBoard().players:
				if player.UUID == pid:
					var dif = myVars.buffsApplied
					card.power -= dif
					card.toughness -= dif
					card.maxToughness -= dif
					myVars.buffsApplied -= dif
					break

func combine(abl : Ability):
	.combine(abl)
	var total = myVars.buffsApplied + abl.myVars.buffsApplied
	myVars.buffsApplied = total
	abl.myVars.buffsApplied = total

func genDescription(subCount = 0) -> String:
	return .genDescription() + "This creature gets +" + str(myVars.count) + "/+" + str(myVars.count) + " for each card removed from its controller's deck"
