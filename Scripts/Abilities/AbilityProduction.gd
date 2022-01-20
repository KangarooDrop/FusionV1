extends Ability

class_name AbilityProduction

var buff = 1

func _init(card : Card).("Production", "This creature creates a mech at the start of your turn", card):
	pass

func onStartOfTurn(board):
	.onStartOfTurn(board)
	for i in range(buff):
		card.addCreatureToBoard(ListOfCards.getCard(5), board)
	
func combine(abl : Ability):
	.combine(abl)
	buff += abl.buff
	desc = "This creature create " + str(buff) + " mechs at the start of your turn"
	
func _to_string():
	return name + " x" + str(buff) +" - " + desc
	
func clone(card : Card) -> Ability:
	var abl = get_script().new(card)
	abl.buff = buff
	return abl
