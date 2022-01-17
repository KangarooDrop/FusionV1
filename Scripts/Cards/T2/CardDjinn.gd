extends CardCreature

class_name CardDjinn

func _init(params).(params if params != null else {"name":"Djinn", "card_type":Card.CARD_TYPE.Creature, "tex":load("res://Art/portraits/card_DJINN.png"), "power":2, "toughness":1, "creature_type":[CardCreature.CREATURE_TYPE.Fire, CardCreature.CREATURE_TYPE.Water], "tier":2}):
	abilities.append(AbilityDash.new(self))
	abilities.append(AbilityWisdom.new(self))
