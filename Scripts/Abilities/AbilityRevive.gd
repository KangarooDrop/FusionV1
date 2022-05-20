extends Ability

class_name AbilityRevive

func _init(card : Card).("Revive", card, Color.purple, false, Vector2(0, 0)):
	pass

func onOtherDeath(slot):
	if is_instance_valid(slot.cardNode) and slot.cardNode.card.playerID == self.card.playerID and is_instance_valid(self.card.cardNode) and self.card.cardNode.slot.currentZone == CardSlot.ZONES.HAND:
		if slot.cardNode.card.toughness <= 0 or slot.cardNode.card.isDying:
			slot.cardNode.card.toughness = 1
			if slot.cardNode.card.maxToughness < 1:
				slot.cardNode.card.maxToughness = 1
			slot.cardNode.card.isDying = false
			discardSelf(self.card)
			#NodeLoc.getBoard().fuseToSlot(slot, [card])

func genDescription(subCount = 0) -> String:
	return .genDescription() + "If a creature you control would die, its health becomes 1 and you discard this card"
