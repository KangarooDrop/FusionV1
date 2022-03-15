extends Ability

class_name AbilityEssenceDrain

func _init(card : Card).("Essence Drain", "When this creature is played, all other creatures get -1/-1. Gain +1 power for each creature affected. Removes this ability", card, Color.black, true, Vector2(0, 0)):
	pass

func onEnter(board, slot):
	.onEnter(board, slot)
	onEffect(board)
	
func onEnterFromFusion(board, slot):
	.onEnterFromFusion(board, slot)
	onEffect(board)

func onEffect(board):
	var n = 0
	for s in board.boardSlots:
		if is_instance_valid(s.cardNode) and s.cardNode.card != null and s != card.cardNode.slot:
			s.cardNode.card.power -= count
			s.cardNode.card.toughness -= count
			s.cardNode.card.maxToughness -= count
			n += 1
			
	card.power += count * n
	
	card.removeAbility(self)

func combine(abl : Ability):
	.combine(abl)
	var strCount = str(count)
	desc = "When this creature is played, all other creatures get -" + strCount + "/-" + strCount + ". Gain +" + strCount + " power for each creature affected. Removes this ability"
