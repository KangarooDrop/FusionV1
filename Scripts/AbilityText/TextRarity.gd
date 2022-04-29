extends Ability

class_name TextRarity

var colors = \
[
	Color(0, 0, 0), 
	Color(0.85, 0.85, 1),
	Color(.5, .5, .5), 
	Color(1, 0.6, 0),
	Color(1, 0, 1),
]

func _init(card : Card).("", card, Color.lightgray, false, Vector2(0, 0)):
	pass

func setCount(count : int) -> Ability:
	var r = .setCount(count)
	self.c = colors[count]
	self.name = Card.RARITY.keys()[count].capitalize()
	return r

func genDescription(subCount = 0) -> String:
	if count == 1:
		return .genDescription() + "A deck can have any numbe of Basic cards"
	elif count == 2:
		return .genDescription() + "A deck can have up to 4 of the same Common card"
	elif count == 3:
		return .genDescription() + "A deck can have only 1 of the same Legendary card"
	elif count == 4:
		return .genDescription() + "A deck can have only 1 Vanguard card. It's basically commander"
	
	return .genDescription() + "uh-oh"
