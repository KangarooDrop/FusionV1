extends AbilityETB

class_name AbilityLandslide

func _init(card : Card).("Landslide", card, Color.darkgray, false, Vector2(0, 0)):
	pass
	
func onApplied(slot):
	addToStack("onEffect", [])
			
func onEffect(params):
	if not ListOfCards.isInZone(card, CardSlot.ZONES.CREATURE):
		return
	
	var board = NodeLoc.getBoard()
	var playerID = self.card.playerID
	
	for p in board.players:
		if p.UUID == playerID:
			var found = false
			for i in p.hand.nodes.size():
				if ListOfCards.hasAbility(p.hand.nodes[i].card, get_script()):
					found = true
					break
			if found:
				var cards = []
				
				if is_instance_valid(self.card.cardNode):
					cards.append(card)
				
				for i in p.hand.nodes.size():
					var cardNode = p.hand.nodes[i]
					if ListOfCards.hasAbility(cardNode.card, get_script()):
						cards.append(cardNode.card)
						
						if ListOfCards.canFuseCards(cards):
							p.hand.discardIndex(i)
						else:
							cards.remove(cards.size()-1)
				
				cards.remove(0)
				
				if self.card.cardNode.slot.currentZone == CardSlot.ZONES.CREATURE:
					board.fuseToSlot(self.card.cardNode.slot, cards)
				
			return

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creature is played, fuse all cards with " + str(self) + " from its controller's hand to it that are able"
