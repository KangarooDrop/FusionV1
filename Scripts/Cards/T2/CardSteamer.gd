extends CardCreature

class_name CardSteamer

func _init(params).(params if params != null else {"name":"Steamer", "card_type":Card.CARD_TYPE.Creature, "tex":load("res://Art/portraits/card_STEAMER.png"), "power":1, "toughness":2, "creature_type":[CardCreature.CREATURE_TYPE.Mech, CardCreature.CREATURE_TYPE.Water], "tier":2}):
	abilities.append(AbilityProduction.new(self))
	abilities.append(AbilityWisdom.new(self))
