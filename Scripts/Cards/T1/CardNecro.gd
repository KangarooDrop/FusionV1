extends CardCreature

class_name CardNecro

func _init(params).(params if params != null else {"name":"Necro", "card_type":Card.CARD_TYPE.Creature, "tex":load("res://Art/portraits/card_NECRO.png"), "power":1, "toughness":1, "creature_type":CardCreature.CREATURE_TYPE.Necro, "tier":1}):
	pass

func onDeath(board):
	.onDeath(board)
	for slot in board.creatures[playerID]:
		if is_instance_valid(slot.cardNode):
			slot.cardNode.card.power += 1
			slot.cardNode.card.toughness += 1
