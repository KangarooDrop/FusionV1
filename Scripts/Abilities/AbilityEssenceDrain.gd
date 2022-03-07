extends Ability

class_name AbilityEssenceDrain

func _init(card : Card).("Essence Drain", "When this creature is played, all creatures gain -1/-1. Gain +1/+1 for each creature affected. Removes this ability", card, Color.black, true, Vector2(0, 0)):
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
		if is_instance_valid(s.cardNode) and s.cardNode.card != null:
			s.cardNode.card.power -= count
			s.cardNode.card.toughness -= count
			n += 1
	card.power += count * n
	card.toughness += count * n
			
	card.removeAbility(self)

func combine(abl : Ability):
	.combine(abl)
	var strCount = str(count)
	desc = "When this creature is played, all creatures gain -" + strCount + "/-" + strCount + ". Gain +" + strCount + "/+" + strCount + " for each creature affected. Removes this ability"
