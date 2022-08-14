
class_name Card

var cardNodeScene = load("res://Scenes/CardNode.tscn")

enum CREATURE_TYPE {None, Null, Fire, Water, Earth, Beast, Mech, Necro}
enum RARITY {NONE, BASIC, COMMON, LEGENDARY, VANGUARD}

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
var isDying : bool = false

var rarity : int

var hasAttacked = false
var cantAttackSources = []
var canFuseThisTurn = true
var canBePlayed = true
var playedThisTurn = false

var cardNode
var playerID = -1
var ownerID = -1

var params

func _init(params):
	self.params = params
	if params.has("UUID"):
		UUID = int(params["UUID"])
	name = params["name"]
	texture = load(params["tex"])
	tier = int(params["tier"])
	if params.has("player_id"):
		playerID = params["player_id"]
			
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
		playedThisTurn = params["played_this_turn"]
	else:
		playedThisTurn = true
	if params.has("rarity"):
		rarity = RARITY[params["rarity"]]
	
	if params.has("max_toughness"):
		maxToughness = params["max_toughness"]
	else:
		maxToughness = toughness

	if params.has("abilities"):
		for abl in params["abilities"]:
			var abilityLoaded = ListOfCards.deserializeAbility(abl, self)
			addAbility(abilityLoaded)
			
	if params.has("removed_abilities"):
		for abl in params["removed_abilities"]:
			var abilityLoaded = ListOfCards.deserializeAbility(abl, self)
			removedAbilities.append(abilityLoaded)


func _physics_process(delta):
	var abls = abilities.duplicate()
	abls.invert()
	for abl in abls:
		abl._physics_process(delta)

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
	playedThisTurn = true
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
	hasAttacked = false
	playedThisTurn = false
	
	var abls = abilities.duplicate()
	abls.invert()
	for abl in abls:
		abl.onLeave()
	
func onStartOfTurn():
	if NodeLoc.getBoard().players[NodeLoc.getBoard().activePlayer].UUID == playerID:
		hasAttacked = false
		if NodeLoc.getBoard().isOnBoard(self):
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
				
func onFusion():
	var abls = abilities.duplicate()
	abls.invert()
	for abl in abls:
		abl.onFusion()
	
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

func onAdjustCost(card) -> int:
	var costAdjustment = 0
	for abl in abilities.duplicate():
		costAdjustment += abl.onAdjustCost(card)
	return costAdjustment

func onCardsPlayed(slot, cards):
	var abls = abilities.duplicate()
	abls.invert()
	for abl in abls:
		abl.onCardsPlayed(slot, cards)

func onActivate(index : int):
	if index >= 0 and index < abilities.size():
		var abl = abilities[index]
		
		var abls = abilities.duplicate()
		abls.invert()
		for a in abls:
			a.onOtherActivate(abl)
		
		abl.onActivate()


func addCreatureToBoard(card, slot = null) -> bool:
	if slot == null:
		for s in NodeLoc.getBoard().creatures[playerID]:
			if not is_instance_valid(s.cardNode):
				slot = s
				break
	if slot != null and not is_instance_valid(slot.cardNode):
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
			if c != card:
				c.onOtherEnter(slot)
		
		NodeLoc.getBoard().checkState()
		
		return true
	return false

func canAttack() -> bool:
	return cantAttackSources.size() == 0 and not hasAttacked and not playedThisTurn

func canAttackAutomatic() -> bool:
	return cantAttackSources.size() == 0

func _to_string() -> String:
	return name + " - " + str(power) + "/" + str(toughness)

func clone(resetAbilities := false) -> Card:
	var c : Card = ListOfCards.getCard(UUID)
	c.abilities.clear()
	c.power = power
	c.toughness = toughness
	c.creatureType = creatureType
	c.maxToughness = maxToughness
	c.rarity = rarity
	c.hasAttacked = hasAttacked
	c.playedThisTurn = playedThisTurn
	c.playerID = playerID
	c.ownerID = ownerID
	for abl in abilities:
		if resetAbilities:
			c.addAbility(abl.cloneBase(c))
		else:
			c.addAbility(abl.clone(c))
	for abl in removedAbilities:
		c.removedAbilities.append(abl.cloneBase(c))
	return c

func copyBase() -> Card:
	return get_script().new(null)
	
func serialize() -> Dictionary:
	var rtn = {}
	rtn["UUID"] = UUID
	rtn["rarity"] = RARITY.keys()[rarity]
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
		rtn["abilities"].append(abl.serialize())
	for abl in removedAbilities:
		rtn["removed_abilities"].append(abl.serialize())
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
	
	var addActivate = is_instance_valid(cardNode) and is_instance_valid(cardNode.slot)
	
	if abilities.size() > 0:
		string += "\n"
	for i in range(abilities.size()):
		var abl = abilities[i]
		var activeString = ""
		if addActivate and abl.has_method("onActivate"):
			if abl.canActivate():
				activeString = " -- [color=#" + abl.c.to_html(false) +"][url=activate||" + str(i) + "]<Activate>[/url][/color]"
			else:
				activeString = " -- [color=#" + Color.black.to_html(false) +"]<Activate>[/color]"
		string += "\n" + str(abl) + str(activeString)
	
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

func fuseToSelf(card):
	var uniques = []
	for t in (creatureType + card.creatureType):
		if not uniques.has(t) and t != CREATURE_TYPE.Null:
			uniques.append(t)
	
	var canFuse = (uniques.size() <= 2)
	var types = []
	
	if uniques.size() == 0:
		pass
	elif uniques.size() == 1:
		if (creatureType + card.creatureType).has(CREATURE_TYPE.Null):
			types = [uniques[0], CREATURE_TYPE.Null]
		else:
			types = [uniques[0], uniques[0]] 
				
	elif uniques.size() == 2:
		types = uniques
	else:
		return null
	
	var newTier = max(2, min(ListOfCards.MAX_TIER, self.tier + card.tier)) 
	var numTypes = types.size()
	var newIndex
	
	if numTypes == 0:
		newIndex = ListOfCards.fusionList[0]
	else:
		newIndex = ListOfCards.fusionList[newTier][types[0]][types[1]]
		if newIndex == null:
			newIndex = ListOfCards.fusionList[newTier][types[1]][types[0]]
	
	if newIndex == -1:
		if creatureType.has(CREATURE_TYPE.Null):
			newIndex = card.UUID
		else:
			newIndex = UUID
	
	var newCard = ListOfCards.getCard(newIndex)
	
	UUID = newCard.UUID
	name = newCard.name
	tier = newCard.tier
	texture = newCard.texture
	creatureType = newCard.creatureType
	
	power = power + card.power
	toughness = toughness + card.toughness
	maxToughness = maxToughness + card.maxToughness
	
	for abl in card.abilities:
		addAbility(abl.clone(self))
	for abl in card.removedAbilities:
		removedAbilities.append(abl.clone(self))
	trimAbilities()
	
	rarity = max(rarity, card.rarity)
	
	onFusion()
	
	if is_instance_valid(cardNode):
		cardNode.setCardVisible(cardNode.getCardVisible())
