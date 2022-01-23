extends Ability

class_name AbilityComposite

var buffsApplied = 0

func _init(card : Card).("Composite", "Gains +1/+0 for each other creature you control", card, Color.gray, true):
	pass

func onEnter(board, slot):
	for i in range(count - buffsApplied):
		onEffect(board, slot)
		buffsApplied += 1

func onEnterFromFusion(board, slot):
	for i in range(count - buffsApplied):
		onEffect(board, slot)
		buffsApplied += 1
	
func onEffect(board, slot):
	for s in board.creatures[card.cardNode.slot.playerID]:
		if is_instance_valid(s.cardNode) and s != slot:
			card.power += 1

func onOtherEnter(board, slot):
	card.power += count
	
func onLeave(board):
	for s in board.creatures[card.cardNode.slot.playerID]:
		if is_instance_valid(s.cardNode) and s != card.cardNode.slot:
			card.power -= count
	
func onOtherLeave(board, slot):
	card.power -= count
	
func clone(card : Card) -> Ability:
	var abl = .clone(card)
	abl.buffsApplied = buffsApplied
	return abl
	
func combine(abl : Ability):
	.combine(abl)
	abl.buffsApplied += buffsApplied
