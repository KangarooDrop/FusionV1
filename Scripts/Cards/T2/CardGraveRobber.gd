extends CardCreature

class_name CardGraveRobber

func _init(params).(params if params != null else {"name":"Grave Robber", "card_type":Card.CARD_TYPE.Creature, "tex":load("res://Art/portraits/card_DRIFTER.png"), "power":1, "toughness":3, "creature_type":CardCreature.CREATURE_TYPE.Necro, "tier":2}):
	pass

func onDeath(board):
	.onDeath(board)
	for slot in board.creatures[playerID]:
		if is_instance_valid(slot.cardNode):
			slot.cardNode.card.power += 1
			slot.cardNode.card.toughness += 1

func onBeingAttacked(attacker, board):
	.onBeingAttacked(attacker, board)
	power += 1
	toughness += 1

