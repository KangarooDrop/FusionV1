
class_name Card

var cardNodeScene = load("res://Scenes/CardNode.tscn")

enum CREATURE_TYPE {None, Null, Fire, Water, Earth, Beast, Mech, Necro}
enum RARITY {NONE, COMMON, LEGENDARY, VANGUARD}

var UUID = -1

var name : String
var texture : Texture
var tier : int
var abilities := []
var removedAbilities := []
var creatureType := []
var power : int
var toughness : int
var maxToughness : int

var rarity : int

var hasAttacked = false
var cantAttackSources = []
var canFuseThisTurn = true
var canBePlayed = true
var playedThisTurn = false

var params

var cardNode
var playerID = -1
var ownerID = -1

func _init(params):
	self.params = params
	if params.has("UUID"):
		UUID = int(params["UUID"])
	name = params["name"]
	texture = load(params["tex"])
	tier = int(params["tier"])
	if params.has("player_id"):
		playerID = params["player_id"]
	if params.has("abilities"):
		for abl in params["abilities"]:
			var ablData = abl.rsplit(" ")
			var found = false
			
			for data in ProjectSettings.get_setting("_global_script_classes"):
				if data["class"] == ablData[0]:
					var abilityLoaded = load(data["path"]).new(self)
					if ablData.size() > 1:
						abilityLoaded.setCount(int(ablData[1]))
					addAbility(abilityLoaded)
					found = true
			if not found:
				print("ERROR LOADING CARD: COULD NOT FIND ABILITY ", abl)
	if params.has("removed_abilities"):
		for abl in params["removed_abilities"]:
			for data in ProjectSettings.get_setting("_global_script_classes"):
				if data["class"] == abl:
					removedAbilities.append(load(data["path"]).new(self))
			
	if params.has("creature_type"):
		for c in params["creature_type"]:
			creatureType.append(int(c))
	if params.has("power"):
		power = int(params["power"])
	if params.has("toughness"):
		toughness = int(params["toughness"])
	if params.has("has_attacked"):
		hasAttacked = params["has_attacked"]
#	if params.has("can_attack"):
#		canAttackThisTurn = params["can_attack"]
	if params.has("can_play"):
		canBePlayed = params["can_play"]
	if params.has("played_this_turn"):
		playedThisTurn = params.has("played_this_turn")
	else:
		playedThisTurn = true
	if params.has("rarity"):
		rarity = RARITY[params["rarity"]]
	
	if params.has("max_toughness"):
		maxToughness = params["max_toughness"]
	else:
		maxToughness = toughness

func onHoverEnter(slot):
	var abls = abilities.duplicate()
	abls.invert()
	for abl in abls:
		abl.onHoverEnter(slot)

func onHoverExit(slot):
	var abls = abilities.duplicate()
	abls.invert()
	for abl in abls:
		abl.onHoverExit(slot)

func onEnter(slot):
	var abls = abilities.duplicate()
	abls.invert()
	for abl in abls:
		abl.onEnter(slot)
	
func onOtherEnter(slot):
	var abls = abilities.duplicate()
	abls.invert()
	for abl in abls:
		abl.onOtherEnter(slot)
	
func onOtherDeath(slot):
	var abls = abilities.duplicate()
	abls.invert()
	for abl in abls:
		abl.onOtherDeath(slot)
	
func onOtherLeave(slot):
	var abls = abilities.duplicate()
	abls.invert()
	for abl in abls:
		abl.onOtherLeave(slot)
	
func onDeath():
	var abls = abilities.duplicate()
	abls.invert()
	for abl in abls:
		abl.onDeath()
	
func onLeave():
	var abls = abilities.duplicate()
	abls.invert()
	for abl in abls:
		abl.onLeave()
	
func onStartOfTurn():
	if NodeLoc.getBoard().isOnBoard(self) and NodeLoc.getBoard().players[NodeLoc.getBoard().activePlayer].UUID == playerID:
		hasAttacked = false
		canFuseThisTurn = true
		playedThisTurn = false
	var abls = abilities.duplicate()
	abls.invert()
	for abl in abls:
		abl.onStartOfTurn()

func onEndOfTurn():
	var abls = abilities.duplicate()
	abls.invert()
	for abl in abls:
		abl.onEndOfTurn()
				
func onFusion(card):
	var abls = abilities.duplicate()
	abls.invert()
	for abl in abls:
		abl.onFusion(card)
	
func onEnterFromFusion(slot):
	var abls = abilities.duplicate()
	abls.invert()
	for abl in abls:
		abl.onEnterFromFusion(slot)
	
func onOtherEnterFromFusion(slot):
	var abls = abilities.duplicate()
	abls.invert()
	for abl in abls:
		abl.onOtherEnterFromFusion(slot)

func onDraw(card):
	var abls = abilities.duplicate()
	abls.invert()
	for abl in abls:
		abl.onDraw(card)

func onMill(card):
	var abls = abilities.duplicate()
	abls.invert()
	for abl in abls:
		abl.onMill(card)

func onGraveAdd(card):
	var abls = abilities.duplicate()
	abls.invert()
	for abl in abls:
		abl.onGraveAdd(card)

func onKill(slot):
	var abls = abilities.duplicate()
	abls.invert()
	for abl in abls:
		abl.onKill(slot)

func onKilledBy(slot):
	var abls = abilities.duplicate()
	abls.invert()
	for abl in abls:
		abl.onKilledBy(slot)

func onOtherKilled(slot):
	var abls = abilities.duplicate()
	abls.invert()
	for abl in abls:
		abl.onOtherKilled(slot)

func onBeforeDamage(attacker, blocker):
	var abls = abilities.duplicate()
	abls.invert()
	for abl in abls:
		abl.onBeforeDamage(attacker, blocker)

func onAfterDamage(attacker, blocker):
	var abls = abilities.duplicate()
	abls.invert()
	for abl in abls:
		abl.onAfterDamage(attacker, blocker)

func onOtherBeforeDamage(attacker, blocker):
	var abls = abilities.duplicate()
	abls.invert()
	for abl in abls:
		abl.onOtherBeforeDamage(attacker, blocker)

func onOtherAfterDamage(attacker, blocker):
	var abls = abilities.duplicate()
	abls.invert()
	for abl in abls:
		abl.onOtherAfterDamage(attacker, blocker)

func onTakeDamage(card):
	toughness -= max(card.power, 0)
	
	var abls = abilities.duplicate()
	abls.invert()
	for abl in abls:
		abl.onTakeDamage(card)

func onDealDamage(slot):
	var abls = abilities.duplicate()
	abls.invert()
	for abl in abls:
		abl.onDealDamage(slot)

func onOtherTakeDamage(attacker, blocker):
	var abls = abilities.duplicate()
	abls.invert()
	for abl in abls:
		abl.onOtherTakeDamage(attacker, blocker)

func onOtherDealDamage(attacker, blocker):
	var abls = abilities.duplicate()
	abls.invert()
	for abl in abls:
		abl.onOtherDealDamage(attacker, blocker)

func onBeforeCombat(attacker, blockers):
	var abls = abilities.duplicate()
	abls.invert()
	for abl in abls:
		abl.onBeforeCombat(attacker, blockers)

func onAfterCombat(attacker, blockers):
	var abls = abilities.duplicate()
	abls.invert()
	for abl in abls:
		abl.onAfterCombat(attacker, blockers)

func onAdjustCost(card, cost) -> int:
	var costAdjustment = 0
	for abl in abilities.duplicate():
		costAdjustment += abl.onAdjustCost(card, cost)
	return costAdjustment

func onCardsPlayed(slot, cards):
	var abls = abilities.duplicate()
	abls.invert()
	for abl in abls:
		abl.onCardsPlayed(slot, cards)
	

func addCreatureToBoard(card, slot = null) -> bool:
	if slot == null:
		for s in NodeLoc.getBoard().creatures[playerID]:
			if not is_instance_valid(s.cardNode):
				slot = s
				break
	if slot != null:
		card.playerID = playerID
		
		var cardPlacing = cardNodeScene.instance()
		cardPlacing.card = card
		NodeLoc.getBoard().add_child(cardPlacing)
		cardPlacing.global_position = slot.global_position
		slot.cardNode = cardPlacing
		cardPlacing.slot = slot
		cardPlacing.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
		card.cardNode = cardPlacing
		
		card.onEnter(slot)
		for c in NodeLoc.getBoard().getAllCards():
			if c != self:
				c.onOtherEnter(slot)
		return true
	return false

func canAttack() -> bool:
	return cantAttackSources.size() == 0 and not hasAttacked and not playedThisTurn

func _to_string() -> String:
	return name + " - " + str(power) + "/" + str(toughness)

func clone() -> Card:
	var c : Card = ListOfCards.getCard(UUID)
	c.power = power
	c.toughness = toughness
	c.creatureType = creatureType
	c.maxToughness = maxToughness
	for abl in abilities:
		c.addAbility(abl.clone(c))
	for abl in removedAbilities:
		c.removedAbilities.append(abl.clone(c))
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
	rtn["played_this_turn"] = playedThisTurn
	rtn["abilities"] = []
	rtn["removed_abilities"] = []
	rtn["can_play"] = canBePlayed
	for abl in abilities:
		rtn["abilities"].append(abl.get_script())
	for abl in removedAbilities:
		rtn["removed_abilities"].append(abl.get_script())
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
	
	string += str(load("res://Scripts/AbilityText/TextRarity.gd").new(null).setCount(rarity)) + "\n"
	
	string += "Types: "
	for i in range(creatureType.size()):
		string += CREATURE_TYPE.keys()[creatureType[i]].to_lower().capitalize()
		if i < creatureType.size() - 1:
			string += " / "
	
	if abilities.size() > 0:
		string += "\n"
	for abl in abilities:
		string += "\n" + str(abl)
	
	if removedAbilities.size() > 0:
		string += "\n----------"
	for abl in removedAbilities:
		string += "\n[s]" + str(abl) + "[/s]"
		
	return string

func trimAbilities():
	var newAbilities = []
	var foundAbilities = []
	while abilities.size() > 0:
		var foundAbility = false
		for abl in abilities.duplicate():
			if abl != abilities[0] and abl is abilities[0].get_script() and not foundAbilities.has(abl) and not foundAbilities.has(abilities[0]):
				cantAttackSources.erase(abl)
				abilities[0].combine(abl)
				abilities.erase(abl)
				foundAbility = true
				foundAbilities.append(abl)
				break
		if not foundAbility:
			newAbilities.append(abilities[0])
			abilities.remove(0)
	abilities = newAbilities

func addAbility(ability):
	abilities.append(ability)
	trimAbilities()
	if is_instance_valid(cardNode) and cardNode.iconsShowing:
		cardNode.removeIcons()
		cardNode.addIcons()

func removeAbility(ability):
	for abl in abilities.duplicate():
		abl.onRemove(ability)
	abilities.erase(ability)
	removedAbilities.append(ability)

func heal(amount : int) -> bool:
	amount = min(amount, maxToughness - toughness)
	amount = max(amount, 0)
	if amount > 0:
		toughness += amount
		return true
	else:
		return false
