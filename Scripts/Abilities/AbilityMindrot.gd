extends Ability

class_name AbilityMindrot

func _init(card : Card).("Mindrot", card, Color.blue, true, Vector2(0, 0)):
	pass

func onEnter(board, slot):
	.onEnter(board, slot)
	onEffect(board, slot)
	
func onEnterFromFusion(board, slot):
	.onEnterFromFusion(board, slot)
	onEffect(board, slot)

func onEffect(board, slot):
	board.abilityStack.append([get_script(), "onMillEffect", [board, card.playerID, count]])
	card.removeAbility(self)

static func onMillEffect(params):
	for p in params[0].players:
		if p.UUID != params[1]:
			for i in range(params[2]):
				p.deck.mill(params[0], p.UUID)

func genDescription() -> String:
	return "When this creature is played, remove the top " + str(count) + " cards of your opponent's deck from the game"
