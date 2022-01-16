extends CardCreature

class_name CardFlameCannon

func _init(params).(params if params != null else {"name":"Flame Cannon", "card_type":Card.CARD_TYPE.Creature, "tex":load("res://Art/portraits/card_FLAME_CANNON.png"), "power":2, "toughness":1, "creature_type":CardCreature.CREATURE_TYPE.Fire, "tier":2}):
	if params == null:
		hasAttacked = false

func onStartOfTurn(board):
	.onStartOfTurn(board)
	addCreatureToBoard(ListOfCards.getCard(5), board)
	
