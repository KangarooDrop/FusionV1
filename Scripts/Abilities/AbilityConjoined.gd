extends Ability

class_name AbilityConjoined

#Binary reperesentation of creature types that have added stats to the creature
var tribes := 0
var buffsApplied = 0

var threshold = 4

func _init(card : Card).("Conjoined", card, Color.brown, true, Vector2(16, 48)):
	pass

func onHoverEnter(slot):
	for c in NodeLoc.getBoard().graveCards[slot.playerID]:
		for t in c.creatureType:
			onEffect(t)

func onHoverExit(slot):
	onRemove(self)

func onEnter(card):
	for c in NodeLoc.getBoard().graveCards[self.card.playerID]:
		for t in c.creatureType:
			onEffect(t)

func onEnterFromFusion(card):
	for c in NodeLoc.getBoard().graveCards[self.card.playerID]:
		for t in c.creatureType:
			onEffect(t)

func onGraveAdd(card):
	if NodeLoc.getBoard().isOnBoard(self.card):
		if card.playerID == self.card.playerID:
			for t in card.creatureType:
				onEffect(t)

func onRemove(ability):
	if ability == self:
		var c = 0
		var t = tribes
		while t > 0:
			if t & 1 == 1:
				c += 1
			t = t >> 1
		
		if c >= threshold:
			buffsApplied -= count
			self.card.power -= count
			self.card.toughness -= count
			self.card.maxToughness -= count
		tribes = 0

func onEffect(tribe : int):
	tribes |= 1 << tribe
	if buffsApplied < count:
		var c = 0
		var t = tribes
		while t > 0:
			if t & 1 == 1:
				c += 1
			t = t >> 1
		
		if c >= threshold:
			buffsApplied += count
			self.card.power += count
			self.card.toughness += count
			self.card.maxToughness += count

func combine(abl : Ability):
	var total = abl.buffsApplied + buffsApplied
	buffsApplied = total
	abl.buffsApplied = total
	.combine(abl)

func clone(card : Card) -> Ability:
	var abl = .clone(card)
	abl.tribes = tribes
	abl.buffsApplied = buffsApplied
	return abl

func genDescription() -> String:
	return .genDescription() + "When there are " + str(threshold) + " or more creature types in your " + str(TextScrapyard.new(null)) + ", this creature gets +" + str(count) + "/+" + str(count)
