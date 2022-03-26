extends Ability

class_name AbilityPermeation

func _init(card : Card).("Permeation", card, Color.gray, true, Vector2(32, 64)):
	pass

func onStartOfTurn():
	if NodeLoc.getBoard().isOnBoard(card) and NodeLoc.getBoard().players[NodeLoc.getBoard().activePlayer].UUID == card.playerID:
		NodeLoc.getBoard().abilityStack.append([get_script(), "onEffect", [card, count]])

static func onEffect(params):
	for i in params[1]:
		var c = ListOfCards.getCard(56)
		if not params[0].addCreatureToBoard(c):
			for p in NodeLoc.getBoard().getAllPlayers():
				if p.UUID == params[0].playerID:
					p.takeDamage(1, params[0])

func genDescription() -> String:
	if count > 1:
		return  "At the start of your turn, create another " + str(count) + " " + str(TextGreyGoo.new(null)) + " creatures" + ". If you cannot, take 1 damage"
	else:
		return  "At the start of your turn, create another " + str(TextGreyGoo.new(null)) + " creatures" + ". If you cannot, take 1 damage"
