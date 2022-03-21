extends Ability

class_name AbilityConjoined

#Binary reperesentation of creature types that have been added stats to the creature
var tribes := 0

func _init(card : Card).("Conjoined", card, Color.brown, false, Vector2(16, 48)):
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
	if board.isOnBoard(card):
		for t in card.creatureType:
			onEffect(t)

func onEffect(tribe : int):
	if not tribes & 1 << tribe:
		tribes |= 1 << tribe
		self.card.power += 1
		self.card.toughness += 1
		self.card.maxToughness += 1

func combine(abl : Ability):
	.combine(abl)
	tribes |= abl.tribes
	abl.tribes |= tribes

func clone(card : Card) -> Ability:
	var abl = .clone(card)
	abl.tribes = tribes
	return abl

func genDescription() -> String:
	return "This creature gets +1/+1 for each creature types in your " + str(TextScrapyard.new(null))
