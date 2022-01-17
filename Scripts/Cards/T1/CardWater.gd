extends CardCreature

class_name CardWater

func _init(params).(params if params != null else {"name":"Water Elemental", "card_type":Card.CARD_TYPE.Creature, "tex":load("res://Art/portraits/card_WATER.png"), "power":0, "toughness":1, "creature_type":[CardCreature.CREATURE_TYPE.Water], "tier":1}):
	abilities.append(AbilityWisdom.new(self))
