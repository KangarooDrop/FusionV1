extends Ability

class_name AbilityConfigure

func _init(card : Card).("Configure", card, Color.blue, true, Vector2(0, 0)):
	pass

func onEnter(board, slot):
	.onEnter(board, slot)
	onEffect(board, slot)
	
func onEnterFromFusion(board, slot):
	.onEnterFromFusion(board, slot)
	onEffect(board, slot)
			
func onEffect(board, slot):
	for s in board.creatures[card.cardNode.slot.playerID]:
		if is_instance_valid(s.cardNode) and s != slot:
			s.cardNode.card.power += count
			
	card.removeAbility(self)

func genDescription() -> String:
	return "When this creature is played, all other creatures you control gain +" + str(count) + " power. Removes this ability"
