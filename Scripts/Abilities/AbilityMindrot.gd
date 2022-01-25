extends Ability

class_name AbilityMindrot

func _init(card : Card).("Mindrot", "When this card is played, remove the top 3 cards of your opponent's deck from the game", card, Color.blue, true):
	pass

func onEnter(board, slot):
	.onEnter(board, slot)
	onEffect(board, slot)
	
func onEnterFromFusion(board, slot):
	.onEnterFromFusion(board, slot)
	onEffect(board, slot)

func onEffect(board, slot):
	for p in board.players:
		if p.UUID != card.playerID:
			for i in range(count * 3):
				p.deck.mill(board, p.UUID)
			
	var scr = get_script()
	for abl in card.abilities:
		if abl is scr:
			card.abilities.erase(abl)
			break

func combine(abl : Ability):
	.combine(abl)
	desc = "When this creature enters the board, remove the top " + str(count * 3) + "  cards of your opponent's deck from the game"
