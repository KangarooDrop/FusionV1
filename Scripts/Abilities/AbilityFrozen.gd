extends Ability

class_name AbilityFrozen

var frozenThisTurn = false

func _init(card : Card).("Frozen", "This creature cannot attack or be fused until the end of its owners next turn", card, Color.lightblue, false, Vector2(16, 0)):
	pass

func onEnter(board, slot):
	.onEnter(board, slot)
	onEffect()
	
func onEnterFromFusion(board, slot):
	.onEnterFromFusion(board, slot)
	onEffect()

func onStartOfTurn(board):
	.onStartOfTurn(board)
	onEffect()
	if board.players[board.activePlayer].UUID == card.playerID:
		frozenThisTurn = true

func onEffect():
	card.canAttackThisTurn = false
	card.canFuseThisTurn = false
	card.cardNode.setCardVisible(card.cardNode.getCardVisible())
	
func onEndOfTurn(board):
	if frozenThisTurn:
		card.canFuseThisTurn = true
		if board.players[board.activePlayer].UUID == card.playerID:
			var scr = get_script()
			for abl in card.abilities:
				if abl is scr:
					card.abilities.erase(abl)
					break
