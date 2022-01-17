extends CardCreature

class_name CardGraveRobber

func _init(params).(params if params != null else {"name":"Grave Robber", "card_type":Card.CARD_TYPE.Creature, "tex":load("res://Art/portraits/card_DRIFTER.png"), "power":1, "toughness":3, "creature_type":[CardCreature.CREATURE_TYPE.Earth, CardCreature.CREATURE_TYPE.Necro], "tier":2}):
	abilities.append(AbilityTough.new(self))
	abilities.append(AbilitySacrifice.new(self))
