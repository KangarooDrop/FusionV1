extends Ability

class_name AbilityMadness

var buffsApplied := 0

func _init(card : Card).("Madness", card, Color.blue, true, Vector2(0, 0)):
	pass

func onEnter(board, slot):
	onEffect(board)
	
func onEnterFromFusion(board, slot):
	onEffect(board)
	
func onDraw(board, card):
	if board.isOnBoard(card):
		onEffect(board)

func onMill(board, card):
	if board.isOnBoard(card):
		onEffect(board)

func onEffect(board):
	var pid = card.cardNode.slot.playerID
	for player in board.players:
		if player.UUID == pid:
			var num = player.deck.cards.size()
			var dif = num * count - buffsApplied
			card.power -= dif
			card.toughness -= dif
			card.maxToughness -= dif
			buffsApplied += dif
			break

func combine(abl : Ability):
	.combine(abl)
	var total = buffsApplied + abl.buffsApplied
	buffsApplied = total
	abl.buffsApplied = total

func clone(card : Card) -> Ability:
	var abl = .clone(card)
	abl.buffsApplied = buffsApplied
	return abl

func genDescription() -> String:
	return "This creature gets -" + str(count) + "/-" + str(count) + " for each card in your library"
