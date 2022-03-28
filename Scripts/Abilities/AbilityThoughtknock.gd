extends Ability

class_name AbilityThoughtknock

var numCards = 0

func _init(card : Card).("Thoughtknock", card, Color.gray, true, Vector2(0, 0)):
	pass

func onEnter(slot):
	.onEnter(slot)
	addToStack("onEffect", [clone(card)])
	card.removeAbility(self)
	
func onEnterFromFusion(slot):
	.onEnterFromFusion(slot)
	addToStack("onEffect", [clone(card)])
	card.removeAbility(self)

func slotClicked(slot : CardSlot):
	if slot.currentZone == CardSlot.ZONES.HAND and slot.playerID == card.playerID:
		var hand : HandNode = slot.get_parent()
		var index = -1
		for i in range(hand.slots.size()):
			if hand.slots[i] == slot:
				index = i
		hand.discardIndex(index)
		#hand.drawCard()
		numCards += 1
		if numCards >= count:
			NodeLoc.getBoard().endGetSlot()

static func onEffect(params):
	var slectingUUID = -1
	for p in NodeLoc.getBoard().players:
		if p.UUID == params[0].card.playerID:
			if p.hand.nodes.size() == 0:
				return
			else:
				p.hand.reveal()
		else:
			slectingUUID = p.UUID
	NodeLoc.getBoard().getSlot(params[0], slectingUUID)

func genDescription() -> String:
	var c = ""
	if count == 1:
		c = "When this creature is played, reveal your hand and your opponent chooses a card from it. Discard that card. Removes this ability"
	else:
		c = "When this creature is played, reveal your hand and your opponent chooses " + str(count) + " cards" + " from it. Discard those cards. Removes this ability"
	return .genDescription() + c
