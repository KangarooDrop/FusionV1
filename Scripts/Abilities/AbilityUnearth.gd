extends AbilityETB

class_name AbilityUnearth

var graveCards = []

func _init(card : Card).("Unearth", card, Color.darkgray, true, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onEffect", [])

func onEffect(params):
	var total = 0
	var board = NodeLoc.getBoard()
	for p in board.players:
		var g = board.graveCards[p.UUID]
		total += g.size()
	
	if total > 0:
		NodeLoc.getBoard().getSlot(self, card.playerID)
	else:
		pass

func slotClicked(slot : CardSlot):
	var board = NodeLoc.getBoard()
	if slot == null:
		for p in board.players:
			if board.graveCards[p.UUID].size() > 0:
				slot = board.graveCards[p.UUID][randi() % board.graveCards[p.UUID].size()].cardNode.slot
				Server.slotClicked(Server.opponentID, slot.isOpponent, slot.currentZone, slot.get_index(), 1)
				break
	
	if slot.currentZone == CardSlot.ZONES.GRAVE_CARD:
		slot.cardNode.select()
		if not graveCards.has(slot.cardNode.card):
			SoundEffectManager.playSelectSound()
			graveCards.append(slot.cardNode.card)
		else:
			SoundEffectManager.playUnselectSound()
			graveCards.erase(slot.cardNode.card)
		
		var total = 0
		for k in board.graveCards.keys():
			total += board.graveCards[k].size()
		
		if graveCards.size() >= total or graveCards.size() >= count - timesApplied:
			for card in graveCards:
				for p in board.players:
					if p.UUID == self.card.playerID:
						p.hand.addCardToHand([card, false, true])
						break
			
			timesApplied = count
			graveCards.clear()
			NodeLoc.getBoard().endGetSlot()

func genDescription(subCount = 0) -> String:
	var string = " card"
	if count - timesApplied > 1:
		string + " cards"
	return .genDescription() + "When this creature is played, its controller chooses " + str(count - timesApplied) + string + " in any " + str(TextScrapyard.new(null)) +" and adds the card(s) to their hand"
