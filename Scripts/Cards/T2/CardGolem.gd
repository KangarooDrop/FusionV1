extends CardCreature

class_name CardGolem

func _init(params).(params if params != null else {"name":"Golem", "card_type":Card.CARD_TYPE.Creature, "tex":load("res://Art/portraits/card_GOLEM.png"), "power":1, "toughness":1, "creature_type":CardCreature.CREATURE_TYPE.Earth, "tier":2}):
	pass

func onBeingAttacked(attacker, board):
	.onBeingAttacked(attacker, board)
	power += 2
	toughness += 2
