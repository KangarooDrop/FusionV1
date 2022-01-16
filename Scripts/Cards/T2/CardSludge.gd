extends CardCreature

class_name CardSludge

func _init(params).(params if params != null else {"name":"Sludge", "card_type":Card.CARD_TYPE.Creature, "tex":load("res://Art/portraits/card_SLUDGE.png"), "power":0, "toughness":3, "creature_type":CardCreature.CREATURE_TYPE.Earth, "tier":2}):
	pass

func onBeingAttacked(attacker, board):
	.onBeingAttacked(attacker, board)
	power += 1
	toughness += 1

func onEnter(board):
	.onEnter(board)
	for p in board.players:
		if p.UUID == playerID:
			p.hand.drawCard()
