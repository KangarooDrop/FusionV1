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
		self.card.addCreatureToBoard(card, board, self.card.cardNode.slot if i == 0 else null)
