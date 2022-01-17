extends CardCreature

class_name CardCombust

func _init(params).(params if params != null else {"name":"Combust", "card_type":Card.CARD_TYPE.Creature, "tex":load("res://Art/portraits/card_COMBUST.png"), "power":2, "toughness":1, "creature_type":[CardCreature.CREATURE_TYPE.Fire, CardCreature.CREATURE_TYPE.Necro], "tier":2}):
	abilities.append(AbilityDash.new(self))
	abilities.append(AbilitySacrifice.new(self))
