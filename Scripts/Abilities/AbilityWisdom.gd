extends Ability

class_name AbilityWisdom

func _init(card : Card).("Wisedom", "When this creature is played, draw a card. Removes this ability", card, Color.blue, true):
	pass

func onEnter(board, slot):
	.onEnter(board, slot)
	onDrawEffect(board)
	
func onEnterFromFusion(board, slot):
	.onEnterFromFusion(board, slot)
	onDrawEffect(board)
			
func onDrawEffect(board):
	for p in board.players:
		if p.UUID == card.playerID:
			for i in range(count):
				p.hand.drawCard()
			break
			
	var scr = get_script()
	for abl in card.abilities:
		if abl is scr:
			card.abilities.erase(abl)
			break


func combine(abl : Ability):
	.combine(abl)
	desc = "This creature draws " + str(count) + " cards when entering the board"
