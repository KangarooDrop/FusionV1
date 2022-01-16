extends CardCreature

class_name CardCyberWolf

func _init(params).(params if params != null else {"name":"Cerberus", "card_type":Card.CARD_TYPE.Creature, "tex":load("res://Art/portraits/card_CYBER_WOLF.png"), "power":2, "toughness":2, "creature_type":CardCreature.CREATURE_TYPE.Fire, "tier":2}):
	pass

func onStartOfTurn(board):
	.onStartOfTurn(board)
	addCreatureToBoard(ListOfCards.getCard(5), board)
	
