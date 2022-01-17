extends CardCreature

class_name CardCyberWolf

func _init(params).(params if params != null else {"name":"Cyber wolf", "card_type":Card.CARD_TYPE.Creature, "tex":load("res://Art/portraits/card_CYBER_WOLF.png"), "power":2, "toughness":2, "creature_type":[CardCreature.CREATURE_TYPE.Beast, CardCreature.CREATURE_TYPE.Mech], "tier":2}):
	abilities.append(AbilityProduction.new(self))
