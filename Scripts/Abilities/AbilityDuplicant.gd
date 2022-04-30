extends Ability

class_name AbilityDuplicant

func _init(card : Card).("Duplicant", card, Color.blue, false, Vector2(0, 0)):
	pass

func onFusion(card):
	var board = NodeLoc.getBoard()
	if board is BoardMP:
		onEffect(card)

func onEffect(card):
	var cardNew = card.clone()
	cardNew.power = 1
	cardNew.toughness = 1
	
	for abl in card.abilities:
		if abl is get_script():
			card.removeAbility(abl)
	
	for abl in cardNew.abilities:
		if abl is get_script():
			cardNew.abilities.erase(abl)
		elif abl is AbilityETB:
			abl.timesApplied = 0
	
	for p in NodeLoc.getBoard().players:
		if p.UUID == card.playerID:
			p.hand.addCardToHand([cardNew, true, true])
			break

func genDescription(subCount = 0) -> String:
	return .genDescription() + "On fusion, add a 1/1 copy of the card with all abilities. Removes this ability"
