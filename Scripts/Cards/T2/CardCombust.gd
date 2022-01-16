extends CardCreature

class_name CardCombust

func _init(params).(params if params != null else {"name":"Combust", "card_type":Card.CARD_TYPE.Creature, "tex":load("res://Art/portraits/card_COMBUST.png"), "power":2, "toughness":1, "creature_type":CardCreature.CREATURE_TYPE.Necro, "tier":2}):
	if params == null:
		hasAttacked = false

func onDeath(board):
	.onDeath(board)
	for slot in board.creatures[playerID]:
		if is_instance_valid(slot.cardNode):
			slot.cardNode.card.power += 1
			slot.cardNode.card.toughness += 1
