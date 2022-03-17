extends Ability

class_name AbilityShieldUp

func _init(card : Card).("Shield Up", card, Color.darkgray, true, Vector2(0, 0)):
	pass

func onEnter(board, slot):
	.onEnter(board, slot)
	onEffect(board)

func onEnterFromFusion(board, slot):
	.onEnterFromFusion(board, slot)
	onEffect(board)
	
func onEffect(board):
	for p in board.players:
		if p.UUID == card.playerID:
			p.addArmour(count)
	card.removeAbility(self)

func genDescription() -> String:
	return "When this creature is played, gain " + str(count) + " " + str(TextArmor.new(null)) + ". Removes this ability"
