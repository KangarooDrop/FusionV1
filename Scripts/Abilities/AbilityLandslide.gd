extends AbilityETB

class_name AbilityLandslide

func _init(card : Card).("Landslide", card, Color.darkgray, false, Vector2(0, 0)):
	pass
	
func onApplied(slot):
	addToStack("onEffect", [card.cardNode.slot])
			
func onEffect(params):
	
	var board = NodeLoc.getBoard()
	var playerID = params[0].playerID
	
	for p in board.players:
		if p.UUID == playerID:
			var found = false
			for i in p.hand.nodes.size():
				if ListOfCards.hasAbility(p.hand.nodes[i].card, get_script()):
					found = true
					break
			if found:
				var cards = []
				
				if is_instance_valid(params[0].cardNode):
					cards.append(params[0].cardNode.card)
				
				for i in p.hand.nodes.size():
					var cardNode = p.hand.nodes[i]
					if ListOfCards.hasAbility(cardNode.card, get_script()):
						cards.append(cardNode.card)
						
						if ListOfCards.canFuseCards(cards):
							p.hand.discardIndex(i)
						else:
							cards.remove(cards.size()-1)
				
				cards.remove(0)
				
				board.fuseToSlot(params[0], cards)
				
			return

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creature is played, fuse all cards with " + str(self) + " to it that are able to"
