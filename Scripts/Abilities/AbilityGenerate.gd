extends Ability

class_name AbilityGenerate

func _init(card : Card).("Generate", card, Color.gray, true, Vector2(0, 96)):
	pass

func canActivate() -> bool:
	var board = NodeLoc.getBoard()
#	print(board is BoardMP, "  ", not board.getWaiting(), "  ", board.cardsPlayed <= board.cardsPerTurn - 1, "  ", board.isMyTurn(), "  ", board.isOnBoard(card), "  ", card.playerID == board.players[0].UUID)
	return board is BoardMP and not board.getWaiting() and board.cardsPlayed <= board.cardsPerTurn - 1 and board.isMyTurn() and board.isOnBoard(card) and card.playerID == board.players[0].UUID

func onActivate():
	var board = NodeLoc.getBoard()
	board.addCardsPlayed(1)
	addToStack("onEffect", [])
	
func onEffect(params):
	for p in NodeLoc.getBoard().players:
		if p.UUID == card.playerID:
			for i in range(count):
				p.hand.drawCard()
			break

func genDescription(subCount = 0) -> String:
	return .genDescription() + "(1): draw " + str(count) + " cards"

func genStackDescription(subCount) -> String:
	return .genDescription() + "Draw " + str(count) + " cards"
