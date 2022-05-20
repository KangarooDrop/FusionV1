extends Ability

class_name AbilityPermeation

func _init(card : Card).("Permeation", card, Color.gray, true, Vector2(32, 64)):
	pass

func onStartOfTurn():
	if NodeLoc.getBoard().isOnBoard(card) and NodeLoc.getBoard().players[NodeLoc.getBoard().activePlayer].UUID == card.playerID:
		addToStack("onEffect", [])

func onEffect(params):
	for i in myVars.count:
		var c = ListOfCards.getCard(1027)
		if not card.addCreatureToBoard(c):
			for p in NodeLoc.getBoard().getAllPlayers():
				if p.UUID == card.playerID:
					p.takeDamage(1, card)

func genDescription(subCount = 0) -> String:
	if myVars.count > 1:
		return  .genDescription() + "At the start of its controller's turn, this creature creates another " + str(myVars.count) + " " + str(TextCard.new(ListOfCards.getCard(1027))) + ". Its controller takes 1 damage, for each that cannot be created"
	else:
		return  .genDescription() + "At the start of its controller's turn, this creature creates another " + str(TextCard.new(ListOfCards.getCard(1027))) + ". Its controller takes 1 damage if it could not be created"
