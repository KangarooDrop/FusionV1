extends Ability

class_name AbilityDuplicant

func _init(card : Card).("Duplicant", card, Color.blue, false, Vector2(0, 0)):
	pass

func onEnter(slot):
	onEffect(slot)

func onEnterFromFusion(slot):
	onEffect(slot)

func onEffect(slot):
	if is_instance_valid(slot.cardNode):
		var cardNew = ListOfCards.getCard(slot.cardNode.card.UUID)
		cardNew.abilities.clear()
		cardNew.power = 1
		cardNew.toughness = 1
		
		for abl in slot.cardNode.card.abilities + slot.cardNode.card.removedAbilities:
			if not abl is get_script():
				cardNew.addAbility(abl.get_script().new(cardNew).setCount(abl.count))
			elif slot.cardNode.card.abilities.has(abl):
				slot.cardNode.card.removeAbility(abl)
		
		for p in NodeLoc.getBoard().players:
			if p.UUID == card.playerID:
				for i in range(count):
					p.hand.addCardToHand([cardNew, true, false])
				break

func genDescription() -> String:
	return .genDescription() + "On being played, add a 1/1 copy of the card with all abilities and removed abilities to your hand. Removes this ability"
