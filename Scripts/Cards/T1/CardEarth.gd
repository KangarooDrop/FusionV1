extends CardCreature

class_name CardEarth

func _init(params).(params if params != null else {"name":"Earth Elemental", "card_type":Card.CARD_TYPE.Creature, "tex":load("res://Art/portraits/card_ROCK.png"), "power":0, "toughness":1, "creature_type":CardCreature.CREATURE_TYPE.Earth, "tier":1}):
	pass

func onBeingAttacked(attacker, board):
	.onBeingAttacked(attacker, board)
	power += 1
	toughness += 1
