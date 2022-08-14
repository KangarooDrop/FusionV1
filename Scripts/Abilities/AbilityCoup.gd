extends Ability

class_name AbilityCoup

func _init(card : Card).("Coup", card, Color.lightgray, false, Vector2(16, 0)):
	pass

func onOtherBeforeDamage(attacker, blocker):
	.onOtherBeforeDamage(attacker, blocker)
	if NodeLoc.getBoard().isOnBoard(card) and attacker.playerID == card.playerID:
		card.cantAttackSources.erase(self)

func onEnter(slot):
	.onEnter(slot)
	if not hasAttaked() and not card.cantAttackSources.has(self):
		card.cantAttackSources.append(self)

func onEnterFromFusion(slot):
	.onEnterFromFusion(slot)
	if not hasAttaked() and not card.cantAttackSources.has(self):
		card.cantAttackSources.append(self)

func hasAttaked() -> bool:
	for p in NodeLoc.getBoard().players:
		if p.UUID == card.playerID:
			if p.getFlag(Player.CREATURES_ATTACKED).currentTurn > 0:
				return true
	return false

func onStartOfTurn():
	.onStartOfTurn()
	if NodeLoc.getBoard().isOnBoard(card):
		if not card.cantAttackSources.has(self):
			card.cantAttackSources.append(self)

func genDescription(subCount = 0) -> String:
	return .genDescription() + "This creature cannot attack until another creature attacks"
