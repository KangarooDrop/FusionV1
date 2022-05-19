extends Node

const MAX_TIER = 5
var cardKeys = []

var cardList := {}

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
		
		
	[
		[-1,   -1,   -1,       -1,     -1,     -1,     -1,     -1],
		[-1,   -1,   -1,       -1,     -1,     -1,     -1,     -1],
		[-1,   -1,   -1,       null,   null,   null,   null,   null],
		[-1,   -1,   null,     -1,     null,   null,   null,   null],
		[-1,   -1,   null,     null,   -1,     null,   null,   null],
		[-1,   -1,   null,     null,   null,   -1,     null,   null],
		[-1,   -1,   null,     null,   null,   null,   -1,     null],
		[-1,   -1,   null,     null,   null,   null,   null,   -1]
	],
		
	[
		[-1,   -1,   -1,   -1,   -1,   -1,   -1,   -1],
		[-1,   0,    null,  null, null, null, null, null],
		[-1,  100,   100,  null, null, null, null, null],
		[-1,  102,   101,  102,  null, null, null, null],
		[-1,  105,   103,  104,  105,  null, null, null],
		[-1,  109,   106,  107,  108,  109,  null, null],
		[-1,  114,   110,  111,  112,  113,  114,  null],
		[-1,  120,   115,  116,  117,  118,  119,  120]
	],
		
	[
		[-1,   -1,   -1,   -1,   -1,   -1,   -1,   -1],
		[-1,   0,    null,    null,   null,   null,   null,   null],
		[-1,  200,   200,     null,   null,   null,   null,   null],
		[-1,  202,   201,     202,    null,   null,   null,   null],
		[-1,  205,   203,     204,    205,    null,   null,   null],
		[-1,  209,   206,     207,    208,    209,    null,   null],
		[-1,  214,   210,     211,    212,    213,    214,    null],
		[-1,  220,   215,     216,    217,    218,    219,    220]
	],
		
	[
		[-1,   -1,   -1,   -1,   -1,   -1,   -1,   -1],
		[-1,   0,    null,    null,   null,   null,   null,   null],
		[-1,  300,   300,     null,   null,   null,   null,   null],
		[-1,  302,   301,     302,    null,   null,   null,   null],
		[-1,  305,   303,     304,    305,    null,   null,   null],
		[-1,  309,   306,     307,    308,    309,    null,   null],
		[-1,  314,   310,     311,    312,    313,    314,    null],
		[-1,  320,   315,     316,    317,    318,    319,    320]
	],
		
	[
		[-1,   -1,   -1,   -1,   -1,   -1,   -1,   -1],
		[-1,   0,    null,    null,   null,   null,   null,   null],
		[-1,  400,   400,     null,   null,   null,   null,   null],
		[-1,  402,   401,     402,    null,   null,   null,   null],
		[-1,  405,   403,     404,    405,    null,   null,   null],
		[-1,  409,   406,     407,    408,    409,    null,   null],
		[-1,  414,   410,     411,    412,    413,    414,    null],
		[-1,  420,   415,     416,    417,    418,    419,    420]
	]
]

var rarityToCards := []

func _ready():
	var file = File.new()
	file.open("res://database/card_list.json", File.READ)
	var cardDataset : Dictionary = parse_json(file.get_as_text())
	file.close()
	
	for i in range(Card.RARITY.size()):
		rarityToCards.append([])
	
	for k in cardDataset.keys():
		if k == "##COMMENT##":
			continue
		
		var id = int(k)
		
		var dat = cardDataset[k]
		dat["UUID"] = id
		cardList[id] = Card.new(cardDataset[k])
		
		rarityToCards[cardList[id].rarity].append(id)
	
	fuseTest()
			
"""
func addKeyToAllCards(key : String, default_value=""):
	var path = "res://database/card_list.json"
	
	var file = File.new()
	file.open("res://database/card_list.json", File.READ_WRITE)
	var cardDataset : Dictionary = parse_json(file.get_as_text())
	
	FileIO.writeToJSON(path.get_base_dir(), "cards.copy" + str(randi()), cardDataset)
	
#	for k in cardDataset.keys():
#		if k == "##COMMENT##":
#			continue
#		k[key] = default_value
	
#	file.store_line(to_json(var2str(cardDataset)))
	file.close()
"""

func getCard(index : int) -> Card:
	if not index in cardList.keys():
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
	
	var bad = true
	var card = null
	while bad:
		card = ListOfCards.getCard(rarityToCards[rar][randi() % rarityToCards[rar].size()])
		bad = card.tier != 1
	
	return card

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
	for k1 in ListOfCards.cardList.keys():
		var c1 = ListOfCards.getCard(k1)
		if c1.tier == 1:
			for k2 in ListOfCards.cardList.keys():
				var c2 = ListOfCards.getCard(k2)
				if c2.tier == 1:
					if ListOfCards.canFuseCards([c1, c2]):
						var _c = c1.clone().fuseToSelf(c2)
