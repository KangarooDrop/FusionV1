extends CardCreature

class_name CardVolcan

func _init(params).(params if params != null else {"name":"Volcan", "card_type":Card.CARD_TYPE.Creature, "tex":load("res://Art/portraits/card_VOLCAN.png"), "power":2, "toughness":2, "creature_type":[CardCreature.CREATURE_TYPE.Fire, CardCreature.CREATURE_TYPE.Earth], "tier":2}):
	abilities.append(AbilityDash.new(self))
	abilities.append(AbilityTough.new(self))
