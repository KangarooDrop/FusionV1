extends Ability

class_name AbilityConjoined

#Binary reperesentation of creature types that have been added stats to the creature
var tribes := 0

func _init(card : Card).("Conjoined", card, Color.brown, true, Vector2(16, 48)):
	pass


func onEnter(board, slot):
	for c in board.graveCards[slot.playerID]:
		for t in c.creatureType:
			onEffect(t)
	
func onEnterFromFusion(board, slot):
	for c in board.graveCards[slot.playerID]:
		for t in c.creatureType:
			onEffect(t)

func onGraveAdd(board, card):
	if board.isOnBoard(self.card):
		for t in card.creatureType:
			onEffect(t)

func onEffect(tribe : int):
	if not tribes & 1 << tribe:
		tribes |= 1 << tribe
		self.card.power += count
		self.card.toughness += count
		self.card.maxToughness += count

func combine(abl : Ability):
	var t = tribes
	while t > 0:
		if t & 1 == 1:
			self.card.power += abl.count
			self.card.toughness += abl.count
			self.card.maxToughness += abl.count
		t = t >> 1
	
	.combine(abl)
	tribes |= abl.tribes
	abl.tribes |= tribes

func clone(card : Card) -> Ability:
	var abl = .clone(card)
	abl.tribes = tribes
	return abl

func genDescription() -> String:
	return "This creature gets +" + str(count) + "/+" + str(count) +" for each creature type in your " + str(TextScrapyard.new(null))
