extends AbilityETB

class_name AbilityTrawler

var graveIDs = []

func _init(card : Card).("Trawler", card, Color.darkgray, true, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onEffect", [myVars.count - myVars.timesApplied])

func onEffect(params):
	NodeLoc.getBoard().getSlot(self, card.playerID)

func slotClicked(slot : CardSlot):
	var board = NodeLoc.getBoard()
#	if slot == null:
#		for p in NodeLoc.getBoard().players:
#			if p.UUID == card.playerID:
#				slot = p.hand.slots[randi() % p.hand.slots.size()]
#				Server.slotClicked(Server.opponentID, slot.isOpponent, slot.currentZone, slot.get_index(), 1)
#				break
	
	if slot.currentZone == CardSlot.ZONES.GRAVE:
		if not graveIDs.has(slot.playerID):
			SoundEffectManager.playSelectSound()
			graveIDs.append(slot.playerID)
		else:
			SoundEffectManager.playUnselectSound()
			graveIDs.erase(slot.playerID)
		
		if graveIDs.size() >= board.graves.size() or graveIDs.size() >= myVars.count - myVars.timesApplied:
			for id in graveIDs:
				removeCards(id, true)
			NodeLoc.getBoard().endGetSlot()
	
func removeCards(playerID : int, removeCards : bool):
	#Accounting for all tribes in the graveyard
	var board = NodeLoc.getBoard()
	var buffs = 0
	var tribes = 0
	for c in board.graveCards[playerID]:
		for t in c.creatureType:
			tribes |= 1 << t
	
	#Calculating all bits set to 1 in tribes
	while tribes > 0:
		if tribes & 1 == 1:
			buffs += 1
		tribes = tribes >> 1
	
	#Increasing p/t based on number of bits in tribe == 1
	self.card.power += buffs
	self.card.toughness += buffs
	self.card.maxToughness += buffs
	
	if removeCards:
		while(board.graveCards[playerID].size() > 0):
			board.removeCardFromGrave(playerID, 0)

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creature is played, choose a " + str(TextScrapyard.new(null)) +" and remove all cards from it. Gets +1/+1 for each unique creature type removed this way (Includes its own creature types)"
