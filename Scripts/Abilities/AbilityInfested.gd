extends Ability

class_name AbilityInfested

func _init(card : Card).("Infested", "When this creature dies, creates a 1/1 Necro with no abilities", card, Color.black, true, Vector2(32, 96)):
	pass

func onDeath(board):
	.onDeath(board)
	for i in range(count):
		var card = ListOfCards.getCard(21)
		card.abilities.clear()
		card.power = 1
		card.toughness = 1
		self.card.addCreatureToBoard(card, board, null)

func combine(abl : Ability):
	.combine(abl)
	desc = "When this creature dies, creates " + str(count) + " 1/1 Necro with no abilities"
