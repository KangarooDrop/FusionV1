
class_name Card

enum CARD_TYPE {Creature, Spell}

var UUID = -1
var params

var playerID = -1

var name : String
var cardType : int
var texture : Texture
var tier : int

var cardNode

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
	
func onEnter(board, slot):
	cardNode = slot.cardNode
	for abl in abilities:
		abl.onEnter(board, slot)
	
func onOtherEnter(board, slot):
	for abl in abilities:
		abl.onOtherEnter(board, slot)
	
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

func getHoverData() -> String:
	var string = name
	for abl in abilities:
		string += "\n" + str(abl)
	return string
