extends CardCreature

class_name CardCerberus

func _init(params).(params if params != null else {"name":"Cerberus", "card_type":Card.CARD_TYPE.Creature, "tex":load("res://Art/portraits/card_CERBERUS.png"), "power":3, "toughness":2, "creature_type":CardCreature.CREATURE_TYPE.Fire, "tier":2}):
	abilities.append(AbilityDash.new(self))
