extends CardCreature

class_name CardFire

func _init(params).(params if params != null else {"name":"Fire Elemental", "card_type":Card.CARD_TYPE.Creature, "tex":load("res://Art/portraits/card_FIRE.png"), "power":1, "toughness":1, "creature_type":[CardCreature.CREATURE_TYPE.Fire], "tier":1}):
	abilities.append(AbilityDash.new(self))
