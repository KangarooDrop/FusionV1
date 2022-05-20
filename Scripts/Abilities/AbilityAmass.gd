extends AbilityETB

class_name AbilityAmass

func _init(card : Card).("Amass", card, Color.gray, false, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onEffect", [])

func onEffect(params):
	if not is_instance_valid(card.cardNode) or not is_instance_valid(card.cardNode.slot):
		return
	
	var cardList := []
	var toRemove := []
	var board = NodeLoc.getBoard()
	var grave = board.graveCards[card.playerID].duplicate()
	for i in range(grave.size()):
		if grave[i].creatureType == [6] and grave[i].UUID != 61:
			cardList.append(grave[i])
			toRemove.append(i)
			
	toRemove.invert()
	for n in toRemove:
		board.removeCardFromGrave(card.playerID, n)
		
	myVars.timesApplied = myVars.count
	NodeLoc.getBoard().fuseToSlot(card.cardNode.slot, cardList)

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creature is played, fuse all mechs in its controller's " + str(TextScrapyard.new(null)) + " to it"
