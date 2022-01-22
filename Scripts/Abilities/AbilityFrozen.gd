extends Ability

class_name AbilityFrozen

func _init(card : Card).("Frozen", "This creature cannot attack or be fused until the end of its owners next turn", card, Color.lightblue, false):
	pass

func onEnter(board, slot):
	card.canAttackThisTurn = false
	card.canFuseThisTurn = false
	card.cardNode.setCardVisible(card.cardNode.getCardVisible())

func onStartOfTurn(board):
	card.canAttackThisTurn = false
	card.canFuseThisTurn = false
	card.cardNode.setCardVisible(card.cardNode.getCardVisible())
	
func onEndOfTurn(board):
	card.canAttackThisTurn = true
	card.canFuseThisTurn = true
	if board.players[board.activePlayer].UUID == card.playerID:
		var scr = get_script()
		for abl in card.abilities:
			if abl is scr:
				card.abilities.erase(abl)
				break
