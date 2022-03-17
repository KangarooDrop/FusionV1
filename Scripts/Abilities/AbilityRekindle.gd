extends Ability

class_name AbilityRekindle

func _init(card : Card).("Rekindle", card, Color.red, true, Vector2(0, 0)):
	pass

func onEnter(board, slot):
	.onEnter(board, slot)
	onEffect(board)
	
func onEnterFromFusion(board, slot):
	.onEnterFromFusion(board, slot)
	onEffect(board)
	
func onEffect(board):
	board.abilityStack.append([get_script(), "onDiscard", [board, card.playerID]])
	board.abilityStack.append([get_script(), "onDraw", [board, card.playerID, count]])
	
	card.removeAbility(self)

static func onDiscard(params : Array):
	for p in params[0].players:
		if p.UUID == params[1]:
			for i in range(p.hand.nodes.size()):
				p.hand.discardIndex(i)
			break

static func onDraw(params : Array):
	for p in params[0].players:
		if p.UUID == params[1]:
			for i in range(params[2]):
				p.hand.drawCard()
			break
	
func genDescription() -> String:
	return "When this creature is played, discard your hand and draw " + str(count) + " cards. Removes this ability"
