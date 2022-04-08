extends AbilityETB

class_name AbilityAmass

func _init(card : Card).("Amass", card, Color.gray, false, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onEffect", [slot])

static func onEffect(params):
	var cardList := []
	var toRemove := []
	var board = NodeLoc.getBoard()
	var grave = board.graveCards[params[0].playerID].duplicate()
	for i in range(grave.size()):
		if grave[i].creatureType == [6] and grave[i].UUID != 61:
			cardList.append(grave[i])
			toRemove.append(i)
			
	toRemove.invert()
	for n in toRemove:
		board.removeCardFromGrave(params[0].playerID, n)
		
	NodeLoc.getBoard().fuseToSlot(params[0], cardList)

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creature is played, fuse all mechs in your " + str(TextScrapyard.new(null)) + " to it"
