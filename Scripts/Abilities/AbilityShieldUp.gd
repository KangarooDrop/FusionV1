extends Ability

class_name AbilityShieldUp

func _init(card : Card).("Shield Up", "When this creature is played, gain 5 " + str(TextArmor.new(null)) + ". Removes this ability", card, Color.darkgray, true):
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
			p.addArmour(count * 5)
	card.abilities.erase(self)

func combine(abl : Ability):
	.combine(abl)
	desc = "When this creature is played, gain " + str(count * 5) + " armour. Removes this ability"
