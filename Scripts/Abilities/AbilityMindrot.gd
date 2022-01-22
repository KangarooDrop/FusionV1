extends Ability

class_name AbilityMindrot

func _init(card : Card).("Mindrot", "When this creature enters the board, remove the top 3 cards of your opponent's deck from the game", card, Color.blue, true):
	pass

func onEnter(board, slot):
	.onEnter(board, slot)
	for p in board.players:
		if p.UUID != card.playerID:
			for i in range(count):
				p.deck.pop()
			break


func combine(abl : Ability):
	.combine(abl)
	desc = "When this creature enters the board, remove the top " + str(count * 3) + "  cards of your opponent's deck from the game"
