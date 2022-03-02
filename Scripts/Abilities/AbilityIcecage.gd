extends Ability

class_name AbilityIcecage

func _init(card : Card).("Icecage", "When this creature is played, inflict " + str(AbilityFrozen.new(null)) + " on all creatures. Removes this ability", card, Color.blue, true):
	pass

func onEnter(board, slot):
	.onEnter(board, slot)
	onEffect(board)
	
func onEnterFromFusion(board, slot):
	.onEnterFromFusion(board, slot)
	onEffect(board)
			
func onEffect(board):
	for s in board.boardSlots:
		if is_instance_valid(s.cardNode) and s.cardNode.card != null:
			var frozen = AbilityFrozen.new(s.cardNode.card)
			frozen.onEffect()
			s.cardNode.card.abilities.append(frozen)
			
	card.abilities.erase(self)
