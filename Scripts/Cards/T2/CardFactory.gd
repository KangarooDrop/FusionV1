extends CardCreature

class_name CardFactory

func _init(params).(params if params != null else {"name":"Factory", "card_type":Card.CARD_TYPE.Creature, "tex":load("res://Art/portraits/card_FACTORY.png"), "power":1, "toughness":2, "creature_type":CardCreature.CREATURE_TYPE.Mech, "tier":2}):
	pass

func onStartOfTurn(board):
	.onStartOfTurn(board)
	for i in range(2):
		addCreatureToBoard(ListOfCards.getCard(5), board)
		
