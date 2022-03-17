extends Ability

class_name AbilityWisdom

func _init(card : Card).("Wisedom", card, Color.blue, true, Vector2(0, 0)):
	pass

func onEnter(board, slot):
	.onEnter(board, slot)
	onDrawEffect(board)
	
func onEnterFromFusion(board, slot):
	.onEnterFromFusion(board, slot)
	onDrawEffect(board)

func onDrawEffect(board):
	board.abilityStack.append([get_script(), "onDraw", [board, card.playerID, count]])
	card.removeAbility(self)
			
static func onDraw(params : Array):
	for p in params[0].players:
		if p.UUID == params[1]:
			for i in range(params[2]):
				p.hand.drawCard()
			break

func genDescription() -> String:
	return "When this creature is played, draw " + str(count) + (" cards" if count > 1 else " card") + ". Removes this ability"
