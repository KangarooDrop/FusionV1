extends CardCreature

class_name CardGargantua

func _init(params).(params if params != null else {"name":"Gargantua", "card_type":Card.CARD_TYPE.Creature, "tex":load("res://Art/portraits/card_GARGANTUA.png"), "power":3, "toughness":3, "creature_type":[CardCreature.CREATURE_TYPE.Beast], "tier":2}):
	pass
