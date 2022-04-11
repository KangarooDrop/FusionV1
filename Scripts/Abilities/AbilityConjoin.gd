extends AbilityETB

class_name AbilityConjoin

var fuseIndexes := []

func _init(card : Card).("Conjoin", card, Color.lightgray, true, Vector2(16, 48)):
	pass

static func getValidCombinations(cardsInQueue : Array, cardNodesInHand : Array, totalCardsNeeded : int) -> int:
	if cardsInQueue.size() >= totalCardsNeeded:
		return 0
	var total = 0
	for cn in cardNodesInHand:
		if not cn.card in cardsInQueue:
			var tmp = cardsInQueue.duplicate()
			tmp.append(cn.card)
			if ListOfCards.canFuseCards(tmp):
				if tmp.size() < totalCardsNeeded:
					total += getValidCombinations(tmp, cardNodesInHand, totalCardsNeeded)
				else:
					total += 1
			
	
	
	return total

func onApplied(slot):
	addToStack("onEffect", [clone(card), card.playerID, count - timesApplied])

func onEffect(params : Array):
	for p in NodeLoc.getBoard().players:
		if p.UUID == params[1]:
			if p.hand.slots.size() == 0:
				return
	
	NodeLoc.getBoard().getSlot(params[0], params[1])

func slotClicked(slot : CardSlot):
	if slot == null:
		for p in NodeLoc.getBoard().players:
			if p.UUID == card.playerID:
				slot = p.hand.slots[randi() % p.hand.slots.size()]
				break
	
	if slot.currentZone == CardSlot.ZONES.HAND and slot.playerID == card.playerID:
		var hand : HandNode = slot.get_parent()
		var index = -1
		for i in range(hand.slots.size()):
			if hand.slots[i] == slot:
				index = i
		if not fuseIndexes.has(index):
			SoundEffectManager.playSelectSound()
			fuseIndexes.append(index)
			slot.cardNode.position.y -= 16
		else:
			SoundEffectManager.playUnselectSound()
			fuseIndexes.erase(index)
			slot.cardNode.position.y += 16
		
		var tmp = []
		for n in fuseIndexes:
			tmp.append(hand.nodes[n].card)
		
		print("AAAA ", getValidCombinations(tmp, hand.nodes, fuseIndexes.size()+1), "  ", fuseIndexes.size())
		
		#(hand.nodes.size() < count + 1) or 
		if getValidCombinations(tmp, hand.nodes, fuseIndexes.size() + 1) == 0 or fuseIndexes.size() == count + 1 - timesApplied:
			for i in range(fuseIndexes.size()):
				hand.discardIndex(fuseIndexes[i])
			var board = NodeLoc.getBoard()
			board.fuseToHand(hand.player, tmp)
			board.endGetSlot()

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this card is played, fuse " + str(count+1-timesApplied) + " cards together and put the fusion creature into your hand"
