
class_name Deck

var cards : Array

func _init(cards):
	self.cards = cards

func shuffle():
	cards.shuffle()

func pop() -> Card:
	var c = null
	if cards.size() > 0:
		c = cards[0]
		cards.remove(0)
	return c

func draw(count : int) -> Array:
	var c : Array
	for i in range(count):
		if cards.size() > 0:
			c.append(cards.pop_front())
		else:
			pass
	return c

func serialize() -> Array:
	var data = []
	for c in cards:
		data.append(c.serialize())
	return data
	
func deserialize(data):
	cards.clear()
	for d in data:
		cards.append(ListOfCards.deserialize(d))

func _to_string() -> String:
	return str(cards)
