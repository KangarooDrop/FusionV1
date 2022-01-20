extends Ability

class_name AbilityWisdom

var buff = 1

func _init(card : Card).("Wisedom", "This creature draws a card when entering the board", card):
	pass

func onEnter(board, slot):
	.onEnter(board, slot)
	for p in board.players:
		if p.UUID == card.playerID:
			for i in range(buff):
				p.hand.drawCard()
			break


func combine(abl : Ability):
	.combine(abl)
	buff += abl.buff
	desc = "This creature draws " + str(buff) + " cards when entering the board"

func _to_string():
	return name + " x" + str(buff) +" - " + desc

func clone(card : Card) -> Ability:
	var abl = get_script().new(card)
	abl.buff = buff
	return abl
