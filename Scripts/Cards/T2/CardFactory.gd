extends CardCreature

class_name CardFactory

func _init(params).(params if params != null else {"name":"Factory", "card_type":Card.CARD_TYPE.Creature, "tex":load("res://Art/portraits/card_FACTORY.png"), "power":1, "toughness":2, "creature_type":[CardCreature.CREATURE_TYPE.Mech], "tier":2}):
	abilities.append(AbilityProduction.new(self))
	abilities.append(AbilityProduction.new(self))
