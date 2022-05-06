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
		86,
		
		
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
	
	fuseTest()
			

func getCard(index : int) -> Card:
	if index < 0 or index >= cardList.size():
		return null
	var card = cardList[index].get_script().new(cardList[index].params)
	card.UUID = index
	return card

func generateCard() -> Card:
	var vanChance = 0.05
	var legChance = 0.1
	var r = randf()
	var rar = 0
	
	if r < legChance:
		rar = Card.RARITY.LEGENDARY
#	elif r < legChance + vanChance:
#		rar = Card.RARITY.VANGUARD
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
		cards[0].fuseToSelf(cards[1])
		cards.remove(1)
	return cards[0]

static func hasAbility(card : Card, abl) -> bool:
	return getAbility(card, abl) != null

static func getAbility(card : Card, abl):
	for a in card.abilities:
		if a is abl:
			return a
	return null

static func isInZone(card : Card, zone : int) -> bool:
	if card != null and is_instance_valid(card.cardNode) and is_instance_valid(card.cardNode.slot) and card.cardNode.slot.currentZone == zone:
		return true
	else:
		return false

static func fuseTest():
	for i in range(ListOfCards.cardList.size()):
		var c1 = ListOfCards.getCard(i)
		if c1.tier == 1:
			for j in range(ListOfCards.cardList.size()):
				var c2 = ListOfCards.getCard(j)
				if c2.tier == 1:
					if ListOfCards.canFuseCards([c1, c2]):
						var _c = c1.clone().fuseToSelf(c2)
