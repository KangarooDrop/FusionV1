extends Card

class_name CardCreature

var cardNode = preload("res://Scenes/CardNode.tscn")

enum CREATURE_TYPE {None, Null, Fire, Water, Earth, Beast, Mech, Necro}

var creatureType : int
var power : int
var toughness : int

var hasAttacked = true

func _init(params).(params):
	creatureType = params["creature_type"]
	power = params["power"]
	toughness = params["toughness"]
	if params.has("has_attacked"):
		hasAttacked = params["has_attacked"]
	
func serialize() -> Dictionary:
	var rtn = .serialize()
	rtn["creature_type"] = creatureType
	rtn["power"] = power
	rtn["toughness"] = toughness
	rtn["has_attacked"] = hasAttacked
	return rtn
	
func addCreatureToBoard(card, board):
	if board.activePlayer.UUID == playerID:
		for slot in board.creatures[playerID]:
			if not is_instance_valid(slot.cardNode):
				card.playerID = playerID
				
				var cardPlacing = cardNode.instance()
				cardPlacing.card = card
				board.add_child(cardPlacing)
				cardPlacing.global_position = slot.global_position
				slot.cardNode = cardPlacing
				cardPlacing.slot = slot
				
				card.onEnter(board)
				
				return

func onStartOfTurn(board):
	.onStartOfTurn(board)
	if board.activePlayer.UUID == playerID:
		hasAttacked = false
	
	
func onAttack(blocker, board):
	hasAttacked = true
	
func onBeingAttacked(attacker, board):
	pass
	
func _to_string() -> String:
	return ._to_string() + " - " + str(power) + "/" + str(toughness)
