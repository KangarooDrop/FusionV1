extends CardCreature

class_name CardNecroWolf

func _init(params).(params if params != null else {"name":"Necro-Wolf", "card_type":Card.CARD_TYPE.Creature, "tex":load("res://Art/portraits/card_NECRO_WOLF.png"), "power":3, "toughness":2, "creature_type":[CardCreature.CREATURE_TYPE.Beast, CardCreature.CREATURE_TYPE.Necro], "tier":2}):
	abilities.append(AbilitySacrifice.new(self))
