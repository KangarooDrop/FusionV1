extends CardCreature

class_name CardMech

func _init(params).(params if params != null else {"name":"Automaton", "card_type":Card.CARD_TYPE.Creature, "tex":load("res://Art/portraits/card_ROBOT.png"), "power":1, "toughness":1, "creature_type":CardCreature.CREATURE_TYPE.Mech, "tier":1}):
	abilities.append(AbilityProduction.new(self))
