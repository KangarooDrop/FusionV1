extends CardCreature

class_name CardTorrent

func _init(params).(params if params != null else {"name":"Torrent", "card_type":Card.CARD_TYPE.Creature, "tex":load("res://Art/portraits/card_TORRENT.png"), "power":1, "toughness":3, "creature_type":CardCreature.CREATURE_TYPE.Water, "tier":2}):
	pass

func onEnter(board):
	.onEnter(board)
	for p in board.players:
		if p.UUID == playerID:
			p.hand.drawCard()
			p.hand.drawCard()
