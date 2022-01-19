
class_name Card

enum CARD_TYPE {Creature, Spell}

var UUID = -1
var params

var playerID = -1

var name : String
var cardType : int
var texture : Texture
var tier : int

var abilities := []

func _init(params):
	self.params = params
	if params.has("UUID"):
		UUID = params["UUID"]
	name = params["name"]
	cardType = params["card_type"]
	texture = load(params["tex"])
	tier = params["tier"]
	if params.has("player_id"):
		playerID = params["player_id"]
	if params.has("abilities"):
		for abl in params["abilities"]:
			abilities.append(abl.new(self))
	
func onEnter(board):
	for abl in abilities:
		abl.onEnter(board)
	
func onDeath(board):
	for abl in abilities:
		abl.onDeath(board)
	
func onStartOfTurn(board):
	for abl in abilities:
		abl.onStartOfTurn(board)

func onEndOfTurn(board):
	for abl in abilities:
		abl.onEndOfTurn(board)




func _to_string() -> String:
	return name

func clone() -> Card:
	var c : Card = ListOfCards.deserialize(serialize())
	return c
	
func copyBase() -> Card:
	return get_script().new(null)
	
func serialize() -> Dictionary:
	var rtn = {"id":UUID, "player_id":playerID}
	return rtn
	
static func fuseCards(cards : Array) -> Card:
	if cards.size() > 1:
		var c_new = fusePair(cards[0], cards[1])
		cards.remove(0)
		cards.remove(0)
		cards.insert(0, c_new)
		return fuseCards(cards)
	else:
		return cards[0]
	return cards[cards.size() - 1]
	
static func fusePair(cardA : Card, cardB : Card, hasSwapped = false) -> Card:
	var tier = cardA.tier + cardB.tier
	if tier - 2 >= 0 and tier - 2 < ListOfCards.fusionList.size():
		var cardEnd = ListOfCards.fusionList[tier-2][cardA.creatureType[0]][cardB.creatureType[0]]
		if cardEnd == null:
			if hasSwapped:
				return null
			else:
				return fusePair(cardB, cardA)
		elif cardEnd == -1:
			return null
		else:
			var c : Card = ListOfCards.getCard(cardEnd)
			return c
	else:
		return cardB

func getHoverData() -> String:
	var string = name
	for abl in abilities:
		string += "\n" + str(abl)
	return string
