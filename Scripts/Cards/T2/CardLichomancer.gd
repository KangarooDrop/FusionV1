extends CardCreature

class_name CardLichomancer

func _init(params).(params if params != null else {"name":"Lichomancer", "card_type":Card.CARD_TYPE.Creature, "tex":load("res://Art/portraits/card_LICHOMANCER.png"), "power":2, "toughness":1, "creature_type":[CardCreature.CREATURE_TYPE.Necro], "tier":2}):
	abilities.append(AbilitySacrifice.new(self))
	abilities.append(AbilitySacrifice.new(self))
