extends Ability

class_name AbilityEmerge

func _init(card : Card).("Emerge", card, Color.darkgray, false, Vector2(16, 96)):
	pass

func onOtherDeath(slot):
	if not NodeLoc.getBoard().isOnBoard(card) and card.playerID == slot.playerID:
		addToStack("onEffect", [card])

static func onEffect(params):
	if is_instance_valid(params[0].cardNode) and params[0].cardNode.slot.currentZone == CardSlot.ZONES.HAND:
		var card = ListOfCards.getCard(params[0].UUID)
		card.removeAbility(card.abilities[0])
		if params[0].addCreatureToBoard(card, null):
			discardSelf(params[0])

func genDescription() -> String:
	return .genDescription() + "When a creature you control dies, this card is automatically put into play from your hand"
