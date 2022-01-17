extends CardCreature

class_name CardNecro

func _init(params).(params if params != null else {"name":"Necro", "card_type":Card.CARD_TYPE.Creature, "tex":load("res://Art/portraits/card_NECRO.png"), "power":1, "toughness":1, "creature_type":[CardCreature.CREATURE_TYPE.Necro], "tier":1}):
	abilities.append(AbilitySacrifice.new(self))
