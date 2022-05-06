extends AbilityETB

class_name AbilityUnearth

var graveCards = []

func _init(card : Card).("Unearth", card, Color.darkgray, true, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onEffect", [])

func onEffect(params):
	NodeLoc.getBoard().getSlot(self, card.playerID)

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
				for k in board.graveCards.keys():
					var g = board.graveCards[k]
					for i in range(g.size()):
						if g[i] == card:
							board.removeCardFromGrave(k, i)
							break
				
				for p in board.players:
					if p.UUID == self.card.playerID:
						p.hand.addCardToHand([card, true, true])
						break
			
			NodeLoc.getBoard().endGetSlot()

func genDescription(subCount = 0) -> String:
	var string = " card"
	if count - timesApplied > 1:
		string + " cards"
	return .genDescription() + "When this creature is played, its controller chooses " + str(count - timesApplied) + string + " in any " + str(TextScrapyard.new(null)) +" and adds the card(s) to their hand"
