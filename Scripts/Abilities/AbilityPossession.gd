extends Ability

class_name AbilityPossession

func _init(card : Card).("Possession", card, Color.purple, false, Vector2(0, 0)):
	pass

func onOtherBeforeDamage(attacker, blocker):
	if is_instance_valid(blocker.cardNode) and blocker.playerID == card.playerID and not NodeLoc.getBoard().isOnBoard(card) and is_instance_valid(self.card.cardNode) and self.card.cardNode.slot.currentZone == CardSlot.ZONES.HAND:
		addToStack("onEffect", [blocker, card, card.playerID])

static func onEffect(params):
	NodeLoc.getBoard().fuseToSlot(params[0], [params[1]], params[2])
	discardSelf(params[1], false)
	
func genDescription(subCount = 0) -> String:
	return .genDescription() + "When a creature you control is attacked, this card is automatically fused onto it from your hand"
