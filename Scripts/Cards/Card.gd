
class_name Card

var cardNodeScene = load("res://Scenes/CardNode.tscn")

enum CREATURE_TYPE {None, Null, Fire, Water, Earth, Beast, Mech, Necro}

var UUID = -1

var name : String
var texture : Texture
var tier : int
var abilities := []
var creatureType := []
var power : int
var toughness : int

var hasAttacked = true
var canAttackThisTurn = true
var canFuseThisTurn = true

var params

var cardNode
var playerID = -1


func _init(params):
	self.params = params
	if params.has("UUID"):
		UUID = params["UUID"]
	name = params["name"]
	texture = load(params["tex"])
	tier = params["tier"]
	if params.has("player_id"):
		playerID = params["player_id"]
	if params.has("abilities"):
		for abl in params["abilities"]:
			abilities.append(abl.new(self))
			
	if params.has("creature_type"):
		creatureType = params["creature_type"]
	if params.has("power"):
		power = params["power"]
	if params.has("toughness"):
		toughness = params["toughness"]
	if params.has("has_attacked"):
		hasAttacked = params["has_attacked"]
	if params.has("can_attack"):
		canAttackThisTurn = params["can_attack"]
	
func onEnter(board, slot):
	for abl in abilities.duplicate():
		abl.onEnter(board, slot)
	
func onOtherEnter(board, slot):
	for abl in abilities.duplicate():
		abl.onOtherEnter(board, slot)
	
func onOtherDeath(board, slot):
	for abl in abilities.duplicate():
		abl.onOtherDeath(board, slot)
	
func onOtherLeave(board, slot):
	for abl in abilities.duplicate():
		abl.onOtherLeave(board, slot)
	
func onDeath(board):
	for abl in abilities.duplicate():
		abl.onDeath(board)
	
func onLeave(board):
	for abl in abilities.duplicate():
		abl.onLeave(board)
	
func onStartOfTurn(board):
	if board.players[board.activePlayer].UUID == playerID:
		hasAttacked = false
		canAttackThisTurn = true
		canFuseThisTurn = true
	for abl in abilities.duplicate():
		abl.onStartOfTurn(board)

func onEndOfTurn(board):
	for abl in abilities.duplicate():
		abl.onEndOfTurn(board)
				
func onFusion(card):
	for abl in abilities:
		abl.onFusion(card)
	
func onEnterFromFusion(board, slot):
	for abl in abilities:
		abl.onEnterFromFusion(board, slot)
	
func onOtherEnterFromFusion(board, slot):
	for abl in abilities:
		abl.onOtherEnterFromFusion(board, slot)
	
func onAttack(blocker, board):
	hasAttacked = true
	canAttackThisTurn = false
	for abl in abilities.duplicate():
		abl.onAttack(blocker, board)
	
func onBeingAttacked(attacker, board):
	for abl in abilities.duplicate():
		abl.onBeingAttacked(attacker, board)
	
func addCreatureToBoard(card, board, slot = null):
	if slot == null:
		for s in board.creatures[playerID]:
			if not is_instance_valid(s.cardNode):
				slot = s
				break
	if slot != null:
		card.playerID = playerID
		
		var cardPlacing = cardNodeScene.instance()
		cardPlacing.card = card
		board.add_child(cardPlacing)
		cardPlacing.global_position = slot.global_position
		slot.cardNode = cardPlacing
		cardPlacing.slot = slot
		cardPlacing.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
		
		card.onEnter(board, slot)
		for s in board.creatures[slot.playerID]:
			if is_instance_valid(s.cardNode) and s != slot:
				s.cardNode.card.onOtherEnter(self, slot)

func _to_string() -> String:
	return name + " - " + str(power) + "/" + str(toughness)

func clone() -> Card:
	var c : Card = ListOfCards.deserialize(serialize())
	return c
	
func copyBase() -> Card:
	return get_script().new(null)
	
func serialize() -> Dictionary:
	var rtn = {}
	rtn["id"] = UUID
	rtn["name"] = name
	rtn["tier"] = tier
	rtn["tex"] = texture.resource_path
	rtn["player_id"] = playerID
	rtn["power"] = power
	rtn["toughness"] = toughness
	rtn["has_attacked"] = hasAttacked
	rtn["can_attack"] = canAttackThisTurn
	rtn["abilities"] = []
	for abl in abilities:
		rtn["abilities"].append(abl.get_script())
	rtn["creature_type"] = creatureType
	
	return rtn

static func areIdentical(dict1 : Dictionary, dict2 : Dictionary) -> bool:
	var keys1 = dict1.keys()
	var keys2 = dict2.keys()
	
	for k in keys1:
		if not dict2.has(k):
			return false
		else:
			if k == "abilities":
				var a1 = dict1[k]
				var a2 = dict2[k]
				for abl in a1:
					if not a2.has(abl):
						return false
				for abl in a2:
					if not a1.has(abl):
						return false
					
			else:
				if dict1[k] != dict2[k]:
					return false
					
	for k in keys2:
		if not dict1.has(k):
			return false
		else:
			if k == "abilities":
				pass
			else:
				if dict1[k] != dict2[k]:
					return false
	
	return true

func getHoverData() -> String:
	var string = name + "\n"
	
	string += "Types: "
	for i in range(creatureType.size()):
		string += CREATURE_TYPE.keys()[creatureType[i]].to_lower().capitalize()
		if i < creatureType.size() - 1:
			string += " / "
	
	if abilities.size() > 0:
		string += "\n"
	for abl in abilities:
		string += "\n" + str(abl)
		
	return string

func trimAbilities():
	var newAbilities = []
	var foundAbilities = []
	while abilities.size() > 0:
		var foundAbility = false
		for abl in abilities:
			if abl != abilities[0] and abl is abilities[0].get_script() and not foundAbilities.has(abl) and not foundAbilities.has(abilities[0]):
				abilities[0].combine(abl)
				abilities.erase(abl)
				foundAbility = true
				foundAbilities.append(abl)
				break
		if not foundAbility:
			newAbilities.append(abilities[0])
			abilities.remove(0)
	abilities = newAbilities
