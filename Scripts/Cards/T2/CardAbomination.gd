extends CardCreature

class_name CardAbomination

func _init(params).(params if params != null else {"name":"Abomination", "card_type":Card.CARD_TYPE.Creature, "tex":load("res://Art/portraits/card_ABOMINATION.png"), "power":1, "toughness":1, "creature_type":[CardCreature.CREATURE_TYPE.Necro, CardCreature.CREATURE_TYPE.Mech], "tier":2}):
	abilities.append(AbilitySacrifice.new(self))
	abilities.append(AbilityProduction.new(self))
