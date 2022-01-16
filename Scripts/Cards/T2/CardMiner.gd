extends CardCreature

class_name CardMiner

func _init(params).(params if params != null else {"name":"Miner", "card_type":Card.CARD_TYPE.Creature, "tex":load("res://Art/portraits/card_Miner.png"), "power":1, "toughness":2, "creature_type":CardCreature.CREATURE_TYPE.Mech, "tier":2}):
	pass

func onBeingAttacked(attacker, board):
	.onBeingAttacked(attacker, board)
	power += 1
	toughness += 1

func onStartOfTurn(board):
	.onStartOfTurn(board)
	addCreatureToBoard(ListOfCards.getCard(5), board)
	
