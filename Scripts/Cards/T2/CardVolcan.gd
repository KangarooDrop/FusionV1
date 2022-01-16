extends CardCreature

class_name CardVolcan

func _init(params).(params if params != null else {"name":"Volcan", "card_type":Card.CARD_TYPE.Creature, "tex":load("res://Art/portraits/card_VOLCAN.png"), "power":2, "toughness":2, "creature_type":CardCreature.CREATURE_TYPE.Fire, "tier":2}):
	if params == null:
		hasAttacked = false

func onBeingAttacked(attacker, board):
	.onBeingAttacked(attacker, board)
	power += 1
	toughness += 1
