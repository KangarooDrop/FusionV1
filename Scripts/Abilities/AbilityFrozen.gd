extends Ability

class_name AbilityFrozen

var frozenThisTurn = false

func _init(card : Card).("Frozen", card, Color.lightblue, false, Vector2(16, 0)):
	pass

func onEnter(slot):
	.onEnter(slot)
	onEffect()

func onEnterFromFusion(slot):
	.onEnterFromFusion(slot)
	onEffect()

func onStartOfTurn():
	.onStartOfTurn()
	if NodeLoc.getBoard().isOnBoard(card):
		onEffect()
		if NodeLoc.getBoard().players[NodeLoc.getBoard().activePlayer].UUID == card.playerID:
			frozenThisTurn = true

func onEffect():
	card.canAttackThisTurn = false
	card.canFuseThisTurn = false
	card.cardNode.setCardVisible(card.cardNode.getCardVisible())

func onEndOfTurn():
	if NodeLoc.getBoard().isOnBoard(card):
		if frozenThisTurn:
			card.canFuseThisTurn = true
			if NodeLoc.getBoard().players[NodeLoc.getBoard().activePlayer].UUID == card.playerID:
				var scr = get_script()
				for abl in card.abilities:
					if abl is scr:
						card.abilities.erase(abl)
						break

func combine(abl : Ability):
	.combine(abl)
	frozenThisTurn = frozenThisTurn and abl.frozenThisTurn

func genDescription() -> String:
	return "This creature cannot attack or be fused until the end of its owners next turn"
