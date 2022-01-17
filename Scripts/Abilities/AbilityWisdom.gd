extends Ability

class_name AbilityWisdom

func _init(card : Card).("Wisedom", "This creature draws a card when entering the board", card):
	pass

func onEnter(board):
	.onEnter(board)
	for p in board.players:
		if p.UUID == card.playerID:
			p.hand.drawCard()
