extends Ability

class_name AbilitySacrifice

func _init(card : Card).("Sacrifice", "This creature gives your other creatures on board +1/+1 when it dies", card):
	pass

func onDeath(board):
	.onDeath(board)
	for slot in board.creatures[card.playerID]:
		if is_instance_valid(slot.cardNode):
			slot.cardNode.card.power += 1
			slot.cardNode.card.toughness += 1
