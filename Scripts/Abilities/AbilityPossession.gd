extends Ability

class_name AbilityPossession

func _init(card : Card).("Possession", card, Color.gray, false, Vector2(0, 0)):
	if card != null:
		card.canBePlayed = false

func onOtherBeingAttacked(board, attacker, blocker):
	if blocker.playerID == card.playerID and not board.isOnBoard(card):
		board.abilityStack.append([get_script(), "onEffect", [board, blocker, card]])
		card.removeAbility(self)

static func onEffect(params):
	params[0].fuseToSlot(params[1], [params[2]])
	discardSelf(params[0], params[2])
	
func genDescription() -> String:
	return "Cannot be played. When a creature you control is attacked, this card is automatically fused onto it from your hand"
