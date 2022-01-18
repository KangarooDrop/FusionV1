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
	[
		[-1,   -1,   -1,   -1,   -1,    -1,  -1,   -1],
		[-1,   0,    1,    2,    3,     4,   5,    21],
		[-1,   0,    6,    null, null, null, null, null],
		[-1,   0,    7,    8,    null, null, null, null],
		[-1,   0,    9,    10,   11,   null, null, null],
		[-1,   0,   12,    13,   14,   15,   null, null],
		[-1,   0,   16,    17,   18,   19,   20,   null],
		[-1,   0,   22,    23,   24,   25,   26,   27]
	]
#	[
#		[-1, 	-1, 	-1, 	-1, 	-1, 	-1, 	-1, 	-1],
#		[-1, 	0, 		null, 	null, 	null, 	null, 	null, 	null],
#		[-1, 	0, 		0, 		null, 	null, 	null, 	null, 	null],
#		[-1, 	0, 		0, 		0, 		null, 	null, 	null, 	null],
#		[-1, 	0, 		0, 		0, 		0, 		null, 	null, 	null],
#		[-1, 	0, 		0, 		0, 		0, 		0, 		null, 	null],
#		[-1, 	0, 		0, 		0, 		0, 		0, 		0,	 	null],
#		[-1, 	0, 		0, 		0, 		0, 		0, 		0, 		0]
#	]
]

func _ready():
	cardList.append(CardNullCreature.new(null))
	cardList.append(CardFire.new(null))
	cardList.append(CardWater.new(null))
	cardList.append(CardEarth.new(null))
	cardList.append(CardWolf.new(null))
	cardList.append(CardMech.new(null))
	
	cardList.append(CardFiend.new(null))
	cardList.append(CardDjinn.new(null))
	cardList.append(CardTorrent.new(null))
	cardList.append(CardVolcan.new(null))
	cardList.append(CardSludge.new(null))
	cardList.append(CardGolem.new(null))
	
	cardList.append(CardCerberus.new(null))
	cardList.append(CardLeviathan.new(null))
	cardList.append(CardStoneSerpant.new(null))
	cardList.append(CardGargantua.new(null))
	cardList.append(CardFlameCannon.new(null))
	cardList.append(CardSteamer.new(null))
	cardList.append(CardMiner.new(null))
	cardList.append(CardCyberWolf.new(null))
	cardList.append(CardFactory.new(null))
	
	
	cardList.append(CardNecro.new(null))
	
	cardList.append(CardCombust.new(null))
	cardList.append(CardDrifter.new(null))
	cardList.append(CardGraveRobber.new(null))
	cardList.append(CardNecroWolf.new(null))
	cardList.append(CardAbomination.new(null))
	cardList.append(CardLichomancer.new(null))
	
	
	for i in range(cardList.size()):
		cardList[i].UUID = i

func getCard(index : int) -> Card:
	if index < 0 or index >= cardList.size():
		return null
	var card = cardList[index].get_script().new(null)
	card.UUID = index
	return card

static func deserialize(data : Dictionary) -> Card:
	var card : Card = ListOfCards.getCard(data["id"])
	card.playerID = data["player_id"]
	if card is CardCreature:
		card.power = data["power"]
		card.toughness = data["toughness"]
		card.hasAttacked = data["has_attacked"]
	return card
	
