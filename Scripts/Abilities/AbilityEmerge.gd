extends Ability

class_name AbilityEmerge

func _init(card : Card).("Emerge", card, Color.black, false, Vector2(16, 96)):
	pass

func onOtherDeath(board, slot):
	if not board.isOnBoard(card) and card.playerID == slot.playerID:
		board.abilityStack.append([get_script(), "onEffect", [board, card]])

static func onEffect(params):
	var card = ListOfCards.getCard(params[1].UUID)
	card.removeAbility(card.abilities[0])
	if params[1].addCreatureToBoard(card, params[0], null):
		discardSelf(params[0], params[1])

func genDescription() -> String:
	return "When a creature you control dies, this card is automatically put into play from your hand"
