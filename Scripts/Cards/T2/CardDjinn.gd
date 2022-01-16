extends CardCreature

class_name CardDjinn

func _init(params).(params if params != null else {"name":"Djinn", "card_type":Card.CARD_TYPE.Creature, "tex":load("res://Art/portraits/card_DJINN.png"), "power":2, "toughness":1, "creature_type":CardCreature.CREATURE_TYPE.Fire, "tier":2}):
	if params == null:
		hasAttacked = false

func onEnter(board):
	.onEnter(board)
	for p in board.players:
		if p.UUID == playerID:
			p.hand.drawCard()

