extends Ability

class_name AbilityPyroclast

func _init(card : Card).("Pyroclast", "When this creature is played, it deals 5 damage to you. Removes this ability", card, Color.red, true, Vector2(0, 0)):
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
			
	card.removeAbility(self)


func combine(abl : Ability):
	.combine(abl)
	desc = "When this creature is played, it deals " + str(count * 5) + " damage to you"
