
class_name Deck

var cards : Array

var deckSize : int = -1

static func MIN_DECK_SIZE() -> int:
	return 20 

func _init():
	pass

func setCards(cards : Array, playerID : int, setDeckSize : bool = false):
	self.cards = cards
	for c in cards:
		c.playerID = playerID
	if setDeckSize:
		deckSize = cards.size()

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
		pop()

func draw(count : int) -> Array:
	var c : Array
	for i in range(count):
		if cards.size() > 0:
			c.append(cards.pop_front())
		else:
			pass
	return c

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
	for k in deckData.keys():
		var id = int(k)
		for i in range(int(deckData[k])):
			cards.append(ListOfCards.getCard(id))
	
func getJSONData() -> Dictionary:
	var rtn = {}
	for c in cards:
		if not rtn.has(str(c.UUID)):
			rtn[str(c.UUID)] = 0
		rtn[str(c.UUID)] += 1
	for k in rtn.keys():
		rtn[k] = float(rtn[k])
	return rtn
	
	
enum DECK_VALIDITY_TYPE {VALID, WRONG_TYPE, BAD_KEYS, BAD_KEY_INDEX, UNKNOWN_INDEX, BAD_COUNT, HIGHER_TIERS, WRONG_SIZE, TOO_MANY_LEGENDS}
#deckData [%id%] : %count%
static func verifyDeck(deckData) -> int:
	#var numSameCards = 4
	var maxTier = 1
	var maxID = ListOfCards.cardList.size()
	
	var total = 0
	
	#CHECK IF DECK DATA IS ACTUALLY A DICTIONARY
	if typeof(deckData) != TYPE_DICTIONARY:
		return DECK_VALIDITY_TYPE.WRONG_TYPE
	
	for k in deckData.keys():
		#CHECK IF THE ID AND COUNT ARE INTEGERS
		if typeof(k) != TYPE_STRING or typeof(deckData[k]) != TYPE_REAL:
			return DECK_VALIDITY_TYPE.BAD_KEYS
			
		if not k.is_valid_integer():
			return DECK_VALIDITY_TYPE.BAD_KEY_INDEX 
			
		var key = int(k)
		var count = int(deckData[k])
			
		#CHECK IF INDEX IS WITHIN BOUNDS OF CARD LIST
		if key < 0 or key >= maxID:
			return DECK_VALIDITY_TYPE.UNKNOWN_INDEX
			
		#CHECKS IF THERE ARE TOO MANY OF SAME CARD or LESS THAN ONE CARD
		if count < 1:# or count > numSameCards:
			return DECK_VALIDITY_TYPE.BAD_COUNT
			
		#CHECKS IF THE DECK ONLY USES TIER 1 CARDS
		if ListOfCards.getCard(key).tier != 1:
			return DECK_VALIDITY_TYPE.HIGHER_TIERS
		
		if ListOfCards.getCard(key).rarity == Card.RARITY.LEGENDARY and count != 1:
			return DECK_VALIDITY_TYPE.TOO_MANY_LEGENDS
			
		total += count
		
	#CHECKS IF THERE ARE THE RIGHT NUMBER OF TOTAL CARDS
	if total < MIN_DECK_SIZE():
		return DECK_VALIDITY_TYPE.WRONG_SIZE
		
	return DECK_VALIDITY_TYPE.VALID

