extends CardCreature

class_name CardNullCreature

func _init(params).(params if params != null else {"name":"Null", "card_type":Card.CARD_TYPE.Creature, "tex":load("res://Art/portraits/card_NULL.png"), "power":1, "toughness":1, "creature_type":CardCreature.CREATURE_TYPE.Null, "tier":1}):
	pass
