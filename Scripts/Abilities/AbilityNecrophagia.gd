extends Ability

class_name AbilityNecrophagia

var payed = false

func _init(card : Card).("Necrophagia", card, Color.darkgray, false, Vector2(0, 96)):
	pass

func canActivate() -> bool:
	var board = NodeLoc.getBoard()
	if not board is BoardMP:
		return false
	
	var totalCreatures = 0
	for s in board.creatures[card.playerID]:
		if is_instance_valid(s.cardNode):
			totalCreatures += 1
	
	return not board.getWaiting() and board.cardsPlayed <= board.cardsPerTurn - 1 and board.isMyTurn() and board.isOnBoard(card) and card.playerID == board.players[0].UUID

func onActivate():
	var board = NodeLoc.getBoard()
	board.getSlot(self, card.playerID)
	board.addCardsPlayed(1)
	addToStack("none", [])

func none(params):
	pass

func slotClicked(slot):
	var board = NodeLoc.getBoard()
	if not payed:
		if slot.currentZone == CardSlot.ZONES.CREATURE and slot.playerID == card.playerID and is_instance_valid(slot.cardNode):
			slot.cardNode.card.isDying = true
			board.endGetSlot()
			payed = true
			addToStack("onEffect", [self])
	else:
		if slot.currentZone == CardSlot.ZONES.GRAVE_CARD and is_instance_valid(slot.cardNode):
			var found = false
			for k in board.graveCards.keys():
				if not found:
					var g = board.graveCards[k]
					for i in range(g.size()):
						if g[i] == slot.cardNode.card:
							board.removeCardFromGrave(k, i)
							found = true
							break
			
			board.endGetSlot()
			if found:
				card.addCreatureToBoard(slot.cardNode.card)
			payed = false

func onEffect(params):
	var board = NodeLoc.getBoard()
	var totalDead = 0
	for p in board.players:
		for c in board.graveCards[p.UUID]:
			totalDead += 1
			break
	if totalDead == 0:
		return
	NodeLoc.getBoard().getSlot(params[0], card.playerID)

func clone(card : Card) -> Ability:
	var abl = .clone(card)
	abl.payed = payed
	return abl

func genDescription(subCount = 0) -> String:
	return .genDescription() + "(1), Destroy a creatures you control: Choose a creature in any " + str(TextScrapyard.new(null)) + " and return it to play under your control"

func genStackDescription(subCount) -> String:
	var string = .genDescription()
	if not payed:
		string += "Destroy a creatures you control"
	else:
		string += "Choose a creature in any " + str(TextScrapyard.new(null)) + " and return it to play under your control"
	return string
