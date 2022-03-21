extends Ability

class_name AbilityScavenge

func _init(card : Card).("Scavenge", card, Color.black, true, Vector2(16, 96)):
	pass

func onOtherDeath(board, slot):
	if board.isOnBoard(card) and card.playerID == slot.playerID:
		board.abilityStack.append([get_script(), "onEffect", [card, count]])

static func onEffect(params):
	params[0].power += params[1]
	params[0].toughness += params[1]

func genDescription() -> String:
	return "Gain +" + str(count) + "/+" + str(count) + " when another friendly creature dies"
