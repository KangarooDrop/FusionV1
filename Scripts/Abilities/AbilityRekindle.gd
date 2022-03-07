extends Ability

class_name AbilityRekindle

var buff = 1

func _init(card : Card).("Rekindle", "When this creature is played, discard your hand and draw three cards. Removes this ability", card, Color.red, false, Vector2(0, 0)):
	pass

func onEnter(board, slot):
	.onEnter(board, slot)
	onEffect(board)
	
func onEnterFromFusion(board, slot):
	.onEnterFromFusion(board, slot)
	onEffect(board)
	
func onEffect(board):
	board.abilityStack.append([get_script(), "onDiscard", [board, card.playerID]])
	board.abilityStack.append([get_script(), "onDraw", [board, card.playerID, buff * 3]])
	
	card.removeAbility(self)


func combine(abl : Ability):
	.combine(abl)
	buff += abl.buff
	
func clone(card : Card) -> Ability:
	var abl = get_script().new(card)
	abl.buff = buff
	return abl

static func onDiscard(params : Array):
	for p in params[0].players:
		if p.UUID == params[1]:
			for i in range(p.hand.cardSlotNodes.size()):
				p.hand.discardIndex(i)
			break

static func onDraw(params : Array):
	for p in params[0].players:
		if p.UUID == params[1]:
			for i in range(params[2]):
				p.hand.drawCard()
			break
	
