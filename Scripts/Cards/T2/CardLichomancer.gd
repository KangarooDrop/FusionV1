extends CardCreature

class_name CardLichomancer

func _init(params).(params if params != null else {"name":"Lichomancer", "card_type":Card.CARD_TYPE.Creature, "tex":load("res://Art/portraits/card_LICHOMANCER.png"), "power":2, "toughness":1, "creature_type":CardCreature.CREATURE_TYPE.Necro, "tier":2}):
	pass

func onDeath(board):
	.onDeath(board)
	for slot in board.creatures[playerID]:
		if is_instance_valid(slot.cardNode):
			slot.cardNode.card.power += 2
			slot.cardNode.card.toughness += 2
