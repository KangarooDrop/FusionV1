extends CardCreature

class_name CardDrifter

func _init(params).(params if params != null else {"name":"Drifter", "card_type":Card.CARD_TYPE.Creature, "tex":load("res://Art/portraits/card_DRIFTER.png"), "power":1, "toughness":2, "creature_type":[CardCreature.CREATURE_TYPE.Water, CardCreature.CREATURE_TYPE.Necro], "tier":2}):
	abilities.append(AbilityWisdom.new(self))
	abilities.append(AbilitySacrifice.new(self))
