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
	cardList.append(Card.new({"name":"Null", "tex":"res://Art/portraits/card_NULL.png", "power":2, "toughness":2, "creature_type":[Card.CREATURE_TYPE.Null], "tier":1}))
	cardList.append(Card.new({"name":"Fire Elemental", "tex":"res://Art/portraits/card_FIRE.png", "power":2, "toughness":1, "creature_type":[Card.CREATURE_TYPE.Fire], "tier":1, "abilities":[AbilityDash]}))
	cardList.append(Card.new({"name":"Water Elemental", "tex":"res://Art/portraits/card_WATER.png", "power":1, "toughness":2, "creature_type":[Card.CREATURE_TYPE.Water], "tier":1, "abilities":[AbilityWisdom]}))
	cardList.append(Card.new({"name":"Earth Elemental", "tex":"res://Art/portraits/card_ROCK.png", "power":1, "toughness":2, "creature_type":[Card.CREATURE_TYPE.Earth], "tier":1, "abilities":[AbilityTough]}))
	cardList.append(Card.new({"name":"Wolf", "tex":"res://Art/portraits/card_WOLF.png", "power":3, "toughness":2, "creature_type":[Card.CREATURE_TYPE.Beast], "tier":1}))
	cardList.append(Card.new({"name":"Automaton", "tex":"res://Art/portraits/card_ROBOT.png", "power":1, "toughness":1, "creature_type":[Card.CREATURE_TYPE.Mech], "tier":1, "abilities":[AbilityProduction]}))
	
	cardList.append(Card.new({"name":"Fiend", "tex":"res://Art/portraits/card_FIEND.png", "creature_type":[Card.CREATURE_TYPE.Fire], "tier":2}))
	cardList.append(Card.new({"name":"Djinn", "tex":"res://Art/portraits/card_DJINN.png", "creature_type":[Card.CREATURE_TYPE.Fire, Card.CREATURE_TYPE.Water], "tier":2}))
	cardList.append(Card.new({"name":"Torrent", "tex":"res://Art/portraits/card_TORRENT.png", "creature_type":[Card.CREATURE_TYPE.Water], "tier":2}))
	cardList.append(Card.new({"name":"Volcan", "tex":"res://Art/portraits/card_VOLCAN.png", "creature_type":[Card.CREATURE_TYPE.Fire, Card.CREATURE_TYPE.Earth], "tier":2}))
	cardList.append(Card.new({"name":"Sludge", "tex":"res://Art/portraits/card_SLUDGE.png", "creature_type":[Card.CREATURE_TYPE.Earth, Card.CREATURE_TYPE.Water], "tier":2}))
	cardList.append(Card.new({"name":"Golem", "tex":"res://Art/portraits/card_GOLEM.png", "creature_type":[Card.CREATURE_TYPE.Earth], "tier":2}))
	cardList.append(Card.new({"name":"Cerberus", "tex":"res://Art/portraits/card_CERBERUS.png", "creature_type":[Card.CREATURE_TYPE.Beast, Card.CREATURE_TYPE.Fire], "tier":2}))
	cardList.append(Card.new({"name":"Leviathan", "tex":"res://Art/portraits/card_LEVIATHAN.png", "creature_type":[Card.CREATURE_TYPE.Beast, Card.CREATURE_TYPE.Water], "tier":2}))
	cardList.append(Card.new({"name":"Stone Serpant", "tex":"res://Art/portraits/card_STONE_SERPANT.png", "creature_type":[Card.CREATURE_TYPE.Beast, Card.CREATURE_TYPE.Earth], "tier":2}))
	cardList.append(Card.new({"name":"Gargantua", "tex":"res://Art/portraits/card_GARGANTUA.png", "creature_type":[Card.CREATURE_TYPE.Beast], "tier":2}))
	cardList.append(Card.new({"name":"Flame Cannon", "tex":"res://Art/portraits/card_FLAME_CANNON.png", "creature_type":[Card.CREATURE_TYPE.Fire, Card.CREATURE_TYPE.Mech], "tier":2}))
	cardList.append(Card.new({"name":"Steamer", "tex":"res://Art/portraits/card_STEAMER.png", "creature_type":[Card.CREATURE_TYPE.Mech, Card.CREATURE_TYPE.Water], "tier":2}))
	cardList.append(Card.new({"name":"Miner", "tex":"res://Art/portraits/card_MINER.png", "creature_type":[Card.CREATURE_TYPE.Mech, Card.CREATURE_TYPE.Earth], "tier":2}))
	cardList.append(Card.new({"name":"Cyber wolf", "tex":"res://Art/portraits/card_CYBER_WOLF.png", "creature_type":[Card.CREATURE_TYPE.Beast, Card.CREATURE_TYPE.Mech], "tier":2}))
	cardList.append(Card.new({"name":"Factory", "tex":"res://Art/portraits/card_FACTORY.png", "creature_type":[Card.CREATURE_TYPE.Mech], "tier":2}))
	
	cardList.append(Card.new( {"name":"Necro", "tex":"res://Art/portraits/card_NECRO.png", "power":2, "toughness":1, "creature_type":[Card.CREATURE_TYPE.Necro], "tier":1, "abilities":[AbilitySacrifice]}))
	
	cardList.append(Card.new({"name":"Combust", "tex":"res://Art/portraits/card_COMBUST.png", "creature_type":[Card.CREATURE_TYPE.Fire, Card.CREATURE_TYPE.Necro], "tier":2}))
	cardList.append(Card.new({"name":"Drifter", "tex":"res://Art/portraits/card_DRIFTER.png", "creature_type":[Card.CREATURE_TYPE.Water, Card.CREATURE_TYPE.Necro], "tier":2}))
	cardList.append(Card.new({"name":"Grave Robber", "tex":"res://Art/portraits/card_DRIFTER.png", "creature_type":[Card.CREATURE_TYPE.Earth, Card.CREATURE_TYPE.Necro], "tier":2}))
	cardList.append(Card.new({"name":"Necro-Wolf", "tex":"res://Art/portraits/card_NECRO_WOLF.png", "creature_type":[Card.CREATURE_TYPE.Beast, Card.CREATURE_TYPE.Necro], "tier":2}))
	cardList.append(Card.new({"name":"Abomination", "tex":"res://Art/portraits/card_ABOMINATION.png", "creature_type":[Card.CREATURE_TYPE.Necro, Card.CREATURE_TYPE.Mech], "tier":2}))
	cardList.append(Card.new({"name":"Lichomancer", "tex":"res://Art/portraits/card_LICHOMANCER.png", "creature_type":[Card.CREATURE_TYPE.Necro], "tier":2}))
	
	
	
	cardList.append(Card.new({"name":"Spitfire", "tex":"res://Art/portraits/FireBob.png", "power":1, "toughness":2, "creature_type":[Card.CREATURE_TYPE.Fire], "tier":1, "abilities":[AbilityPronged]}))
	cardList.append(Card.new({"name":"Legionstones", "tex":"res://Art/portraits/Rocks.png", "power":0, "toughness":4, "creature_type":[Card.CREATURE_TYPE.Earth], "tier":1, "abilities":[AbilityPhalanx]}))
	cardList.append(Card.new({"name":"Badger", "tex":"res://Art/portraits/BADger.png", "power":2, "toughness":3, "creature_type":[Card.CREATURE_TYPE.Beast], "tier":1, "abilities":[AbilityRampage]}))
	cardList.append(Card.new({"name":"Bonelord", "tex":"res://Art/portraits/BoneLord.png", "power":1, "toughness":2, "creature_type":[Card.CREATURE_TYPE.Necro], "tier":1, "abilities":[AbilityScavenge]}))
	cardList.append(Card.new({"name":"Slime", "tex":"res://Art/portraits/slime.png", "power":0, "toughness":1, "creature_type":[Card.CREATURE_TYPE.Null], "tier":1, "abilities":[AbilityDegenerate]}))
	cardList.append(Card.new({"name":"Frostling", "tex":"res://Art/portraits/Snowflake.png", "power":1, "toughness":1, "creature_type":[Card.CREATURE_TYPE.Null], "tier":1, "abilities":[AbilityFrozen]}))
	cardList.append(Card.new({"name":"Blighted", "tex":"res://Art/portraits/ToasterToilet.png", "power":-1, "toughness":-1, "creature_type":[Card.CREATURE_TYPE.Null], "tier":1, "abilities":[]}))
	cardList.append(Card.new({"name":"Frost-tongue", "tex":"res://Art/portraits/ToasterToilet.png", "power":0, "toughness":5, "creature_type":[Card.CREATURE_TYPE.Water], "tier":1, "abilities":[AbilityFrostbite]}))
	cardList.append(Card.new({"name":"Chipper", "tex":"res://Art/portraits/ToasterToilet.png", "power":1, "toughness":2, "creature_type":[Card.CREATURE_TYPE.Mech], "tier":1, "abilities":[AbilityComposite]}))
	
	cardList.append(Card.new({"name":"Thought Sapper", "tex":"res://Art/portraits/card_THOUGH_SAPPER.png", "power":3, "toughness":1, "creature_type":[Card.CREATURE_TYPE.Water], "tier":1, "abilities":[AbilityMindrot]}))
	cardList.append(Card.new({"name":"Rust Crawler", "tex":"res://Art/portraits/card_RUST_CRAWLER.png", "power":5, "toughness":1, "creature_type":[Card.CREATURE_TYPE.Mech], "tier":1, "abilities":[AbilityBrittle]}))
	cardList.append(Card.new({"name":"Torchling", "tex":"res://Art/portraits/ToasterToilet.png", "power":1, "toughness":1, "creature_type":[Card.CREATURE_TYPE.Fire], "tier":1, "abilities":[AbilityPyroclast]}))
	cardList.append(Card.new({"name":"The Boulder", "tex":"res://Art/portraits/card_BOULDER.png", "power":0, "toughness":5, "creature_type":[Card.CREATURE_TYPE.Earth], "tier":1, "abilities":[AbilityBulwark]}))
	cardList.append(Card.new({"name":"Serpant", "tex":"res://Art/portraits/card_SERPENT.png", "power":0, "toughness":2, "creature_type":[Card.CREATURE_TYPE.Beast], "tier":1, "abilities":[AbilityVenemous]}))
	cardList.append(Card.new({"name":"Carrion", "tex":"res://Art/portraits/card_CARRION.png", "power":2, "toughness":1, "creature_type":[Card.CREATURE_TYPE.Necro], "tier":1, "abilities":[AbilityInfested]}))
	
	
	#Fire - 1/1 deals 1 additional damage to players
	#Earth - When attacked, deal as much damage taken back to the attacker
	#Beast - 1/3 Serpant
	#Necro - 1/1 Infested - When this creature dies, creature a 0/1 Necro with no abilities
	
	for i in range(cardList.size()):
		cardList[i].UUID = i
		
	var path = "user:/"
	var fileName = "card_list"
	var dict = {}
	for i in range(cardList.size()):
		dict[i] = cardList[i].params
	
	var error = FileIO.writeToJSON(path, fileName, dict)
	if error != 0:
		print("Error: Writing card list to JSON : ", error)
	else:
		print("Card list written to JSON at path: ", path, "/", fileName + ".json")

func getCard(index : int) -> Card:
	if index < 0 or index >= cardList.size():
		return null
	var card = cardList[index].get_script().new(cardList[index].params)
	card.UUID = index
	return card

static func deserialize(data : Dictionary) -> Card:
	var card : Card = ListOfCards.getCard(data["id"])
	card.playerID = data["player_id"]
	return card
	
	
func fuseCards(cards : Array) -> Card:
	if cards.size() > 1:
		var c_new = fusePair(cards[0], cards[1])
		cards.remove(0)
		cards.remove(0)
		cards.insert(0, c_new)
		return fuseCards(cards)
	return cards[0]
	
func fusePair(cardA : Card, cardB : Card, hasSwapped = false) -> Card:
	var uniques = []
	for t in (cardA.creatureType + cardB.creatureType):
		if not uniques.has(t) and t != Card.CREATURE_TYPE.Null:
			uniques.append(t)
			
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
		return cardA
	
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
	cardNew.power = cardA.power + cardB.power
	cardNew.toughness = cardA.toughness + cardB.toughness
	cardNew.abilities.clear()
	for abl in (cardA.abilities + cardB.abilities):
		cardNew.abilities.append(abl.clone(cardNew))
	cardNew.trimAbilities()
	cardNew.hasAttacked = cardA.hasAttacked
	cardNew.canAttackThisTurn = cardA.canAttackThisTurn
	cardNew.canFuseThisTurn = cardA.canFuseThisTurn
	cardA.onFusion(cardNew)
	cardB.onFusion(cardNew)
	return cardNew

func hasAbility(card : Card, abl) -> bool:
	var hasAbl = false
	for a in card.abilities:
		if a is abl:
			hasAbl = true
			return true
	return false
