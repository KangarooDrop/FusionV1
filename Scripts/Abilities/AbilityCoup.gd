extends Ability

class_name AbilityCoup

var frozenThisTurn = false

func _init(card : Card).("Coup", card, Color.lightgray, false, Vector2(16, 0)):
	pass

func onOtherBeforeDamage(attacker, blocker):
	.onOtherBeforeDamage(attacker, blocker)
	if NodeLoc.getBoard().isOnBoard(card) and attacker.playerID == card.playerID:
		card.cantAttackSources.erase(self)

func onEnter(slot):
	.onEnter(slot)
	if not card.cantAttackSources.has(self):
		card.cantAttackSources.append(self)

func onEnterFromFusion(slot):
	.onEnterFromFusion(slot)
	if not card.cantAttackSources.has(self):
		card.cantAttackSources.append(self)

func onStartOfTurn():
	.onStartOfTurn()
	if NodeLoc.getBoard().isOnBoard(card):
		if not card.cantAttackSources.has(self):
			card.cantAttackSources.append(self)
		if NodeLoc.getBoard().players[NodeLoc.getBoard().activePlayer].UUID == card.playerID:
			frozenThisTurn = true

func combine(abl : Ability):
	.combine(abl)
	frozenThisTurn = frozenThisTurn and abl.frozenThisTurn

func genDescription() -> String:
	return .genDescription() + "This creature cannot attack until another creature attacks"
