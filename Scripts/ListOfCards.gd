extends Node

var cardList := []

var cardBackground = preload("res://Art/backgrounds/card_blank.png")
var cardBackgroundActive = preload("res://Art/backgrounds/card_active.png")
var unknownCardTex = preload("res://Art/portraits/card_unknown.png")
var noneCardTex = preload("res://Art/portraits/card_NONE.png")

var creatureTypeImageList = [null, 
		preload("res://Art/types/type_null.png"), 
		preload("res://Art/types/type_fire.png"), 
		preload("res://Art/types/type_water.png"), 
		preload("res://Art/types/type_rock.png"), 
		preload("res://Art/types/type_beast.png"), 
		preload("res://Art/types/type_mech.png"),
		preload("res://Art/types/type_necro.png")]
#{None, Null, Fire, Water, Earth, Beast, Mech, Necro}

var fusionList := \
[
		0,
		
		
		[-1,   -1,   -1,   -1,   -1,   -1,   -1,   -1],
		
	[
		[-1,   -1,   -1,   -1,   -1,   -1,   -1,   -1],
		[-1,   0,    -1,   -1,   -1,   -1,   -1,   -1],
		[-1,   -1,   6,     null, null, null, null, null],
		[-1,   -1,   7,     8,    null, null, null, null],
		[-1,   -1,   9,     10,   11,   null, null, null],
		[-1,   -1,   12,    13,   14,   15,   null, null],
		[-1,   -1,   16,    17,   18,   19,   20,   null],
		[-1,   -1,   22,    23,   24,   25,   26,   27]
	]
]

var rarityToCards := []

func _ready():
	var file = File.new()
	file.open("res://database/card_list.json", File.READ)
	var cardDataset : Dictionary = parse_json(file.get_as_text())
	file.close()
	
#	for k in cardDataset.keys():
#		cardDataset[k]["rarity"] = Card.RARITY.COMMON
#	FileIO.writeToJSON("user://", "card_list_new", cardDataset)
	
	for k in cardDataset.keys():
		var dat = cardDataset[k]
		dat["UUID"] = k
		cardList.append(Card.new(cardDataset[k]))
	
	for i in range(Card.RARITY.size()):
		rarityToCards.append([])
	for i in range(cardList.size()):
		if cardList[i].tier == 1:
			rarityToCards[cardList[i].rarity].append(i)
			

func getCard(index : int) -> Card:
	if index < 0 or index >= cardList.size():
		return null
	var card = cardList[index].get_script().new(cardList[index].params)
	card.UUID = index
	return card

func generateCard() -> Card:
	var legChance = 0.1
	var r = randf()
	var rar = 0
	
	if r < legChance:
		rar = Card.RARITY.LEGENDARY
	else:
		rar = Card.RARITY.COMMON
	
	return ListOfCards.getCard(rarityToCards[rar][randi() % rarityToCards[rar].size()])

static func deserialize(data : Dictionary) -> Card:
	var card : Card = Card.new(data)
	card.playerID = data["player_id"]
	return card
	
func canFuseCards(cards : Array) -> bool:
	var uniques = []
	for c in cards:
		if not c.canFuseThisTurn:
			return false
		
		for t in (c.creatureType):
			if not uniques.has(t) and t != Card.CREATURE_TYPE.Null:
				uniques.append(t)
	
	return uniques.size() <= 2

func fuseCards(cards : Array) -> Card:
	while cards.size() > 1:
		var c_new = fusePair(cards[0], cards[1])
		cards.remove(0)
		cards.remove(0)
		cards.insert(0, c_new)
	return cards[0]
	
func fusePair(cardA : Card, cardB : Card, cardNode : CardNode = null) -> Card:
	if cardA == null or cardB == null:
		return null
	
	var uniques = []
	for t in (cardA.creatureType + cardB.creatureType):
		if not uniques.has(t) and t != Card.CREATURE_TYPE.Null:
			uniques.append(t)
	
	"""
	uniques = cardA.creatureType.duplicate()
	for t in cardB.creatureType:
		if not cardA.creatureType.has(t):
			uniques.append(t)
	print(uniques)
	"""
	
	var canFuse = (uniques.size() <= 2)
	var types = []
	
	if uniques.size() == 0:
		pass
	elif uniques.size() == 1:
		if (cardA.creatureType + cardB.creatureType).has(Card.CREATURE_TYPE.Null):
			types = [uniques[0], Card.CREATURE_TYPE.Null]
		else:
			types = [uniques[0], uniques[0]] 
				
	elif uniques.size() == 2:
		types = uniques
	else:
		return null
	
	var numTypes = types.size()
	var newIndex
	match numTypes:
		0:
			newIndex = fusionList[0]
		1:
			newIndex = fusionList[1][types[0]]
		2:
			newIndex = fusionList[2][types[0]][types[1]]
			if newIndex == null:
				newIndex = fusionList[2][types[1]][types[0]]
	
	if newIndex == -1:
		if cardA.creatureType.has(Card.CREATURE_TYPE.Null):
			newIndex = cardB.UUID
		else:
			newIndex = cardA.UUID
	
	var cardNew = ListOfCards.getCard(newIndex)
	cardNew.playerID = cardA.playerID
	cardNew.ownerID = cardA.ownerID
	cardNew.power = cardA.power + cardB.power
	cardNew.toughness = cardA.toughness + cardB.toughness
	cardNew.maxToughness = cardA.maxToughness + cardB.maxToughness
	cardNew.abilities.clear()
	for abl in (cardA.abilities + cardB.abilities):
		cardNew.addAbility(abl.clone(cardNew))
	for abl in (cardA.removedAbilities + cardB.removedAbilities):
		cardNew.removedAbilities.append(abl.clone(cardNew))
	cardNew.trimAbilities()
	cardNew.hasAttacked = cardA.hasAttacked
	#cardNew.canAttackThisTurn = cardA.canAttackThisTurn
	cardNew.canFuseThisTurn = cardA.canFuseThisTurn
	
	cardNew.cardNode = cardNode
	
	cardA.onFusion(cardNew)
	cardB.onFusion(cardNew)
	
	return cardNew

func hasAbility(card : Card, abl) -> bool:
	return getAbility(card, abl) != null

func getAbility(card : Card, abl):
	for a in card.abilities:
		if a is abl:
			return a
	return null
