extends Ability

class_name AbilityDuplicant

func _init(card : Card).("Duplicant", card, Color.blue, false, Vector2(0, 0)):
	pass

func onFusion(card):
	onEffect(card)

func onEffect(card):
	var cardNew = ListOfCards.getCard(card.UUID)
	cardNew.abilities.clear()
	cardNew.power = 1
	cardNew.toughness = 1
	
	for abl in card.abilities + card.removedAbilities:
		if not abl is get_script():
			cardNew.addAbility(abl.get_script().new(cardNew).setCount(abl.count))
		elif card.abilities.has(abl):
			card.removeAbility(abl)
	
	for p in NodeLoc.getBoard().players:
		if p.UUID == card.playerID:
			p.hand.addCardToHand([cardNew, true, false])
			break

func genDescription(subCount = 0) -> String:
	return .genDescription() + "On fusion, add a 1/1 copy of the card with all abilities. Removes this ability"
