extends Ability

class_name AbilityPermeation

func _init(card : Card).("Permeation", card, Color.gray, true, Vector2(32, 64)):
	pass

func onStartOfTurn():
	if NodeLoc.getBoard().isOnBoard(card) and NodeLoc.getBoard().players[NodeLoc.getBoard().activePlayer].UUID == card.playerID:
		addToStack("onEffect", [count])

func onEffect(params):
	for i in params[0]:
		var c = ListOfCards.getCard(56)
		if not card.addCreatureToBoard(c):
			for p in NodeLoc.getBoard().getAllPlayers():
				if p.UUID == card.playerID:
					p.takeDamage(1, card)

func genDescription(subCount = 0) -> String:
	if count > 1:
		return  .genDescription() + "At the start of its controller's turn, this creature creates another " + str(count) + " " + str(TextCard.new(ListOfCards.getCard(56))) + ". Its controller takes 1 damage, for each that cannot be created"
	else:
		return  .genDescription() + "At the start of its controller's turn, this creature creates another " + str(TextCard.new(ListOfCards.getCard(56))) + ". Its controller takes 1 damage if it could not be created"
