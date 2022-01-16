extends CardCreature

class_name CardWolf

func _init(params).(params if params != null else {"name":"Wolf", "card_type":Card.CARD_TYPE.Creature, "tex":load("res://Art/portraits/card_WOLF.png"), "power":2, "toughness":1, "creature_type":CardCreature.CREATURE_TYPE.Beast, "tier":1}):
	pass
