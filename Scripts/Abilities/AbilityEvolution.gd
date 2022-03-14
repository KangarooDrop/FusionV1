extends Ability

class_name AbilityEvolution

func _init(card : Card).("Evolution", "At the end of your turn, this card gains +1/+1", card, Color.purple, true, Vector2(32, 64)):
	pass

func onEndOfTurn(board):
	if board.players[board.activePlayer].UUID == card.cardNode.playerID:
		card.power += count
		card.toughness += count

func combine(abl : Ability):
	.combine(abl)
	desc = "At the end of your turn, this card gains +" + str(count) + "/+" + str(count)
