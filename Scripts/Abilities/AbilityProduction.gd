extends Ability

class_name AbilityProduction

func _init(card : Card).("Production", card, Color.gray, true, Vector2(0, 0)):
	pass

func onEnter(board, slot):
	.onEnter(board, slot)
	onEffect(board)
	
func onEnterFromFusion(board, slot):
	.onEnterFromFusion(board, slot)
	onEffect(board)
			
func onEffect(board):
	var hand = null
	for p in board.players:
		if p.UUID == card.cardNode.slot.playerID:
			for i in range(count):
				p.hand.addCardToHand([ListOfCards.getCard(5), true, false])
			break
	
	card.removeAbility(self)
	
func genDescription() -> String:
	var string = "a mech"
	if count > 1:
		string = str(count) + " mechs"
	return "When this creature is played, add " + string + " to your hand. Removes this ability"
