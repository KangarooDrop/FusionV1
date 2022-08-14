extends Ability

class_name AbilityEmerge

func _init(card : Card).("Emerge", card, Color.darkgray, false, Vector2(16, 96)):
	pass

func onOtherDeath(slot):
	if not NodeLoc.getBoard().isOnBoard(card) and card.playerID == slot.playerID and not (is_instance_valid(slot.cardNode) and slot.cardNode.card == card) and is_instance_valid(card.cardNode) and card.cardNode.slot.currentZone == CardSlot.ZONES.HAND:
		addToStack("onEffect", [])

func onEffect(params):
	if is_instance_valid(card.cardNode) and card.cardNode.slot.currentZone == CardSlot.ZONES.HAND:
		if card.addCreatureToBoard(card, null):
			discardSelf(card, false)

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When a creature you control dies, this card is automatically put into play from your hand"
