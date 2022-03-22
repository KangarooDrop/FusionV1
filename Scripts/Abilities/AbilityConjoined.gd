extends Ability

class_name AbilityConjoined

#Binary reperesentation of creature types that have added stats to the creature
var tribes := 0
var buffsApplied = 0

var threshold = 4
var statGain = 3

func _init(card : Card).("Conjoined", card, Color.brown, false, Vector2(16, 48)):
	pass

func onDraw(board, card):
	if card == self.card:
		for c in board.graveCards[self.card.cardNode.playerID]:
			for t in c.creatureType:
				onEffect(t)

func onGraveAdd(board, card):
	
	if card.playerID == self.card.playerID:
		for t in card.creatureType:
			onEffect(t)

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
			buffsApplied += 1
			self.card.power += statGain
			self.card.toughness += statGain
			self.card.maxToughness += statGain

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
	return "When there are " + str(threshold) + " or more creature types in your " + str(TextScrapyard.new(null)) + ", this creature gets +" + str(statGain) + "/+" + str(statGain)
