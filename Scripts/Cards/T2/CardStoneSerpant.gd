extends CardCreature

class_name CardStoneSerpant

func _init(params).(params if params != null else {"name":"Stone Serpant", "card_type":Card.CARD_TYPE.Creature, "tex":load("res://Art/portraits/card_STONE_SERPANT.png"), "power":2, "toughness":2, "creature_type":CardCreature.CREATURE_TYPE.Earth, "tier":2}):
	abilities.append(AbilityTough.new(self))
