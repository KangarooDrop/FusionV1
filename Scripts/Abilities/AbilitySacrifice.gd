extends Ability

class_name AbilitySacrifice

func _init(card : Card).("Sacrifice", "This creature gives your other creatures on board +1/+1 when it dies", card, Color.black, true, Vector2(0, 96)):
	pass

func onDeath(board):
	.onDeath(board)
	for slot in board.creatures[card.playerID]:
		if is_instance_valid(slot.cardNode):
			slot.cardNode.card.power += count
			slot.cardNode.card.toughness += count
			
func combine(abl : Ability):
	.combine(abl)
	desc = "This creature gives your other creatures on board +" + str(count) + "/+" + str(count) + " when it dies"
