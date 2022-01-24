extends Ability

class_name AbilityPyroclast

func _init(card : Card).("Pyroclast", "When this creature is played, it deals 5 damage to you", card, Color.red, true):
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
				p.takeDamage(5, card.cardNode)
			break
			
	var scr = get_script()
	for abl in card.abilities:
		if abl is scr:
			card.abilities.erase(abl)
			break


func combine(abl : Ability):
	.combine(abl)
	desc = "When this creature is played, it deals " + str(count * 5) + " damage to you"
