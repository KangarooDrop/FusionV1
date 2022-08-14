extends AbilityETB

class_name AbilityChimera

func _init(card : Card).("Chimera", card, Color.brown, true, Vector2(0, 0)):
	myVars["buffsApplied"] = 0

func onApplied(slot):
	addToStack("onEffect", [card, true])

func onHoverEnter(slot):
	onEffect([slot, false])

func onHoverExit(slot):
	card.power -= myVars.buffsApplied * myVars.count
	card.toughness -= myVars.buffsApplied * myVars.count
	card.maxToughness -= myVars.buffsApplied * myVars.count
	myVars.buffsApplied = 0

func onEffect(params):
	var playerID = params[0].playerID
	var removeCards = params[1]
	var board = NodeLoc.getBoard()
	var tribes = 0
	for c in board.graveCards[playerID]:
		for t in c.creatureType:
			tribes |= 1 << t
	
	#Calculating all bits set to 1 in tribes
	while tribes > 0:
		if tribes & 1 == 1:
			myVars.buffsApplied += 1
		tribes = tribes >> 1
	
	#Increasing p/t based on number of bits in tribe == 1
	self.card.power += myVars.buffsApplied * (myVars.count - myVars.timesApplied)
	self.card.toughness += myVars.buffsApplied * (myVars.count - myVars.timesApplied)
	self.card.maxToughness += myVars.buffsApplied * (myVars.count - myVars.timesApplied)
	
	if removeCards:
		while(board.graveCards[playerID].size() > 0):
			board.removeCardFromGrave(playerID, 0)
		myVars.timesApplied = myVars.count

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creature is played, remove all cards from its controller's " + str(TextScrapyard.new(null)) +". Gets +" + str(myVars.count - subCount) + "/+" + str(myVars.count - subCount) +" for each unique creature type removed this way"
