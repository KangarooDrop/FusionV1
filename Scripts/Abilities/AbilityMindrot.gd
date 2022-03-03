extends Ability

class_name AbilityMindrot

func _init(card : Card).("Mindrot", "When this card is played, remove the top 3 cards of your opponent's deck from the game. Removes this ability", card, Color.blue, true):
	pass

func onEnter(board, slot):
	.onEnter(board, slot)
	onEffect(board, slot)
	
func onEnterFromFusion(board, slot):
	.onEnterFromFusion(board, slot)
	onEffect(board, slot)

func onEffect(board, slot):
	board.abilityStack.append([get_script(), "onMill", [board, card.playerID, count * 3]])
	card.abilities.erase(self)

static func onMill(params):
	for p in params[0].players:
		if p.UUID != params[1]:
			for i in range(params[2]):
				p.deck.mill(params[0], p.UUID)

func combine(abl : Ability):
	.combine(abl)
	desc = "When this creature enters the board, remove the top " + str(count * 3) + "  cards of your opponent's deck from the game"
