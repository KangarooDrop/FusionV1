extends CardCreature

class_name CardStoneSerpant

func _init(params).(params if params != null else {"name":"Stone Serpant", "card_type":Card.CARD_TYPE.Creature, "tex":load("res://Art/portraits/card_STONE_SERPANT.png"), "power":2, "toughness":2, "creature_type":CardCreature.CREATURE_TYPE.Earth, "tier":2}):
	pass

func onBeingAttacked(attacker, board):
	.onBeingAttacked(attacker, board)
	power += 1
	toughness += 1
