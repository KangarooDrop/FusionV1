extends Ability

class_name TextRarity

var colors = [Color(0, 0, 0), Color(.5, .5, .5), Color(1, 0, 1)]

func _init(card : Card).("", card, Color.lightgray, false, Vector2(0, 0)):
	pass

func setCount(count : int) -> Ability:
	var r = .setCount(count)
	self.c = colors[count]
	self.name = Card.RARITY.keys()[count].capitalize()
	return r

func genDescription() -> String:
	if count == 1:
		return .genDescription() + "A deck can have up to 4 of the same common card"
	elif count == 2:
		return .genDescription() + "A deck can have only 1 of the same legendary card"
	return .genDescription() + "uh-oh"
