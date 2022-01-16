extends CardCreature

class_name CardFiend

func _init(params).(params if params != null else {"name":"Fiend", "card_type":Card.CARD_TYPE.Creature, "tex":load("res://Art/portraits/card_FIEND.png"), "power":3, "toughness":1, "creature_type":CardCreature.CREATURE_TYPE.Fire, "tier":2}):
	if params == null:
		hasAttacked = false
