extends CardCreature

class_name CardSteamer

func _init(params).(params if params != null else {"name":"Steamer", "card_type":Card.CARD_TYPE.Creature, "tex":load("res://Art/portraits/card_STEAMER.png"), "power":1, "toughness":2, "creature_type":CardCreature.CREATURE_TYPE.Mech, "tier":2}):
	pass

func onEnter(board):
	.onEnter(board)
	for p in board.players:
		if p.UUID == playerID:
			p.hand.drawCard()

func onStartOfTurn(board):
	.onStartOfTurn(board)
	addCreatureToBoard(ListOfCards.getCard(5), board)
	
