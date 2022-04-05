extends Ability

class_name AbilityPossession

func _init(card : Card).("Possession", card, Color.gray, false, Vector2(0, 0)):
	pass

func onOtherBeforeDamage(attacker, blocker):
	if is_instance_valid(blocker.cardNode) and blocker.playerID == card.playerID and not NodeLoc.getBoard().isOnBoard(card):
		addToStack("onEffect", [blocker, card])
		card.removeAbility(self)

static func onEffect(params):
	NodeLoc.getBoard().fuseToSlot(params[0], [params[1]])
	discardSelf(params[1])
	
func genDescription() -> String:
	return .genDescription() + "When a creature you control is attacked, this card is automatically fused onto it from your hand"
