extends Ability

class_name AbilityConfigure

func _init(card : Card).("Configure", "When this creature is played, all other creatures you control gain +2 power. Removes this ability", card, Color.blue, true):
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
			s.cardNode.card.power += 2 * count
			
	card.abilities.erase(self)

func combine(abl : Ability):
	.combine(abl)
	desc = "When this creature is played, all other creatures you control gain +" + str(count * 2) + " power. Removes this ability"

