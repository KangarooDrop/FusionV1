extends Ability

class_name AbilityFilibuster

func _init(card : Card).("Filibuster", card, Color.blue, true, Vector2(32, 64)):
	pass

func onCardsPlayed(slot, cards):
	for c in cards:
		onEffect(c)

func onEffect(card):
	if NodeLoc.getBoard().isOnBoard(self.card):
		if card.ownerID == self.card.playerID:
			
			if count == 1:
				self.card.removeAbility(self)
			else:
				count -= 1
				self.card.removeAbility(get_script().new(self.card))

func onAdjustCost(card, cost) -> int:
	if NodeLoc.getBoard().isOnBoard(self.card) and card.ownerID == self.card.playerID and cost < NodeLoc.getBoard().cardsPerTurnMax:
		return 1
	else:
		return 0

func genDescription() -> String:
	var string = " card "
	if count > 1:
		string = " " + str(count) + " cards "
	return .genDescription() + "The next" + string + "you play cost 1 more (cannot exceed max number of cards per turn)"
