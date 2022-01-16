extends CardCreature

class_name CardNecroWolf

func _init(params).(params if params != null else {"name":"Necro-Wolf", "card_type":Card.CARD_TYPE.Creature, "tex":load("res://Art/portraits/card_NECRO_WOLF.png"), "power":3, "toughness":2, "creature_type":CardCreature.CREATURE_TYPE.Necro, "tier":2}):
	pass

func onDeath(board):
	.onDeath(board)
	for slot in board.creatures[playerID]:
		if is_instance_valid(slot.cardNode):
			slot.cardNode.card.power += 1
			slot.cardNode.card.toughness += 1
