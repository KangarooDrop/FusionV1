extends Ability

class_name AbilityRekindle

var cardsDiscarded = 2
var cardsDrawn = 3

func _init(card : Card).("Rekindle", card, Color.red, true, Vector2(0, 0)):
	pass

func onEnter(board, slot):
	.onEnter(board, slot)
	onEffect(board)
	
func onEnterFromFusion(board, slot):
	.onEnterFromFusion(board, slot)
	onEffect(board)
	
func onEffect(board):
	board.abilityStack.append([get_script(), "onDiscard", [board, card.playerID, count * cardsDiscarded]])
	board.abilityStack.append([get_script(), "onDrawEffect", [board, card.playerID, count * cardsDrawn]])
	
	card.removeAbility(self)

static func onDiscard(params : Array):
	for p in params[0].players:
		if p.UUID == params[1]:
			print(params[2])
			var n = min(p.hand.nodes.size(), params[2])
			for i in range(n):
				p.hand.discardIndex(i)
			break

static func onDrawEffect(params : Array):
	for p in params[0].players:
		if p.UUID == params[1]:
			for i in range(params[2]):
				p.hand.drawCard()
			break
	
func genDescription() -> String:
	return "When this creature is played, discard your " + str(count * cardsDiscarded) +" leftmost and draw " + str(count * cardsDrawn) + " cards. Removes this ability"
