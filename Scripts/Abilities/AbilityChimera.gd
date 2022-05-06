extends AbilityETB

class_name AbilityChimera

var buffs = 0

func _init(card : Card).("Chimera", card, Color.brown, true, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onEffect", [card, true])

func onHoverEnter(slot):
	onEffect([slot, false])

func onHoverExit(slot):
	card.power -= buffs * count
	card.toughness -= buffs * count
	card.maxToughness -= buffs * count
	buffs = 0

func onEffect(params):
	var playerID = params[0].playerID
	var removeCards = params[1]
	var board = NodeLoc.getBoard()
	var tribes = 0
	for c in board.graveCards[playerID]:
		for t in c.creatureType:
			tribes |= 1 << t
	
	#Accounting for all tribes of the creature not in the graveyard
	if (params[0] is CardSlot and params[0].playerID == card.playerID):
		for t in card.creatureType:
			tribes |= 1 << t
	
	#Calculating all bits set to 1 in tribes
	while tribes > 0:
		if tribes & 1 == 1:
			buffs += 1
		tribes = tribes >> 1
	
	#Increasing p/t based on number of bits in tribe == 1
	self.card.power += buffs * (count - timesApplied)
	self.card.toughness += buffs * (count - timesApplied)
	self.card.maxToughness += buffs * (count - timesApplied)
	
	if removeCards:
		while(board.graveCards[playerID].size() > 0):
			board.removeCardFromGrave(playerID, 0)

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creature is played, remove all cards from its controller's " + str(TextScrapyard.new(null)) +". Gets +" + str(count - subCount) + "/+" + str(count - subCount) +" for each unique creature type removed this way (Includes its own creature types)"
