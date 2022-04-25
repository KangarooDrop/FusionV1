
class_name Deck

var cards : Array

var deckSize : int = -1

var vanguard : Card

static func MIN_DECK_SIZE() -> int:
	return 20 

func _init():
	pass

func setCards(cards : Array, playerID : int, setDeckSize : bool = false):
	self.cards = cards
	for c in cards:
		c.playerID = playerID
		c.ownerID = playerID
	if setDeckSize:
		deckSize = cards.size()

func setVanguard(card : Card):
	self.vanguard = card

func shuffle():
	cards.shuffle()

func pop() -> Card:
	var c = null
	if cards.size() > 0:
		c = cards[0]
		cards.remove(0)
	return c

func mill(playerID):
	if Settings.playAnimations:
		NodeLoc.getBoard().millQueue.append(playerID)
	else:
		NodeLoc.getBoard().addCardToGrave(playerID, pop())

func draw(count : int) -> Array:
	var c : Array
	for i in range(count):
		if cards.size() > 0:
			c.append(cards.pop_front())
		else:
			pass
	return c

func tutor(cardID : int) -> Card:
	var indexes = []
	for i in range(cards.size()):
		if cards[i].UUID == cardID:
			indexes.append(i)
	
	var card = null
	
	if indexes.size() > 0:
		var ind = indexes[randi() % indexes.size()]
		card = cards[ind]
		cards.remove(ind)
	
	return card

func serialize() -> Array:
	var data = []
	for c in cards:
		data.append(c.UUID)
	return data
	
func deserialize(data):
	cards.clear()
	for d in data:
		cards.append(ListOfCards.getCard(d))

func _to_string() -> String:
	return str(cards)
	
#DECK DATA IS NOT VERIFIED BY THIS FUNCTION, MUST BE PERFORMED BEFORE
func readJSONData(deckData : Dictionary):
	cards.clear()
	vanguard = null
	for k in deckData["vanguard"].keys():
		vanguard = ListOfCards.getCard(int(deckData["vanguard"][k]))
	
	for k in deckData["card"].keys():
		var id = int(k)
		for i in range(int(deckData["cards"][k])):
			cards.append(ListOfCards.getCard(id))
	
func getJSONData() -> Dictionary:
	var rtn = {"vanguard":{}, "cards":{}}
	if vanguard != null:
		rtn["vanguard"][str(vanguard.UUID)] = 1.0
	for c in cards:
		if not rtn["cards"].has(str(c.UUID)):
			rtn["cards"][str(c.UUID)] = 0
		rtn["cards"][str(c.UUID)] += 1
	for k in rtn["cards"].keys():
		rtn["cards"][k] = float(rtn["cards"][k])
	return rtn
	
	
enum DECK_VALIDITY_TYPE {VALID, WRONG_TYPE, BAD_KEYS, BAD_KEY_INDEX, UNKNOWN_INDEX, BAD_COUNT, HIGHER_TIERS, WRONG_SIZE, TOO_MANY_LEGENDS, TOO_MANY_VANGUARDS, BAD_CARDS}
#deckData [%id%] : %count%
static func verifyDeck(deckData) -> int:
	#var numSameCards = 4
	var maxTier = 1
	var maxID = ListOfCards.cardList.size()
	
	var total = 0
	
	#CHECK IF DECK DATA IS ACTUALLY A DICTIONARY
	if typeof(deckData) != TYPE_DICTIONARY:
		return DECK_VALIDITY_TYPE.WRONG_TYPE
	
	if deckData.keys() != ["vanguard", "cards"]:
		return DECK_VALIDITY_TYPE.BAD_KEYS
	
	for dat in deckData.keys():
		for k in deckData[dat].keys():
			var error = verifyCardData(k, deckData[dat][k], dat)
			if error != DECK_VALIDITY_TYPE.VALID:
				return error
			
			total += int(deckData[dat][k])
		if dat == "vanguard" and total > 1:
			return DECK_VALIDITY_TYPE.TOO_MANY_VANGUARDS
		
	#CHECKS IF THERE ARE THE RIGHT NUMBER OF TOTAL CARDS
	if total < MIN_DECK_SIZE():
		return DECK_VALIDITY_TYPE.WRONG_SIZE
		
	return DECK_VALIDITY_TYPE.VALID

static func verifyCardData(cardID, cardCount, cardType) -> int:
	
	var maxID = ListOfCards.cardList.size()
	
	#CHECK IF THE ID AND COUNT ARE INTEGERS
	if typeof(cardID) != TYPE_STRING or typeof(cardCount) != TYPE_REAL:
		return DECK_VALIDITY_TYPE.BAD_KEYS
		
	if not cardID.is_valid_integer():
		return DECK_VALIDITY_TYPE.BAD_KEY_INDEX 
		
	var key = int(cardID)
	var count = int(cardCount)
		
	#CHECK IF INDEX IS WITHIN BOUNDS OF CARD LIST
	if key < 0 or key >= maxID:
		return DECK_VALIDITY_TYPE.UNKNOWN_INDEX
		
	#CHECKS IF THERE ARE TOO MANY OF SAME CARD or LESS THAN ONE CARD
	if count < 1:# or count > numSameCards:
		return DECK_VALIDITY_TYPE.BAD_COUNT
	
	var card = ListOfCards.getCard(key)
	
	#CHECKS IF THE DECK ONLY USES TIER 1 CARDS
	if card.tier != 1:
		return DECK_VALIDITY_TYPE.HIGHER_TIERS
	
	if card.rarity == Card.RARITY.LEGENDARY and count != 1:
		return DECK_VALIDITY_TYPE.TOO_MANY_LEGENDS
	
	if card.rarity == Card.RARITY.VANGUARD and count != 1:
		return DECK_VALIDITY_TYPE.TOO_MANY_VANGUARDS
	
	if cardType == "vanguard":
		if card.rarity != Card.RARITY.VANGUARD:
			return DECK_VALIDITY_TYPE.BAD_CARDS
	elif cardType == "cards":
		if card.rarity == Card.RARITY.VANGUARD:
			return DECK_VALIDITY_TYPE.BAD_CARDS
	
	return DECK_VALIDITY_TYPE.VALID
