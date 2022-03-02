extends Ability

class_name AbilityRekindle

var buff = 1

func _init(card : Card).("Rekindle", "When this creature is played, discard your hand and draw three cards. Removes this ability", card, Color.red, false):
	pass

func onEnter(board, slot):
	.onEnter(board, slot)
	onEffect(board)
	
func onEnterFromFusion(board, slot):
	.onEnterFromFusion(board, slot)
	onEffect(board)
	
func onEffect(board):
	for p in board.players:
		if p.UUID == card.playerID:
			for i in range(p.hand.cardSlotNodes.size()):
				p.hand.discardIndex(i)
			
			for i in range(buff):
				p.hand.drawCard()
				p.hand.drawCard()
				p.hand.drawCard()
			break
	
	card.abilities.erase(self)


func combine(abl : Ability):
	.combine(abl)
	buff += abl.buff
	
func clone(card : Card) -> Ability:
	var abl = get_script().new(card)
	abl.buff = buff
	return abl
