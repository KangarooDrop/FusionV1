
class_name Deck

var cards : Array

func _init(cards):
	self.cards = cards

func shuffle():
	cards.shuffle()

func pop() -> Card:
	var c = null
	if cards.size() > 0:
		c = cards[0]
		cards.remove(0)
	return c

func mill(board, playerID):
	board.millQueue.append(playerID)

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
	
	
enum DECK_VALIDITY_TYPE {VALID, WRONG_TYPE, BAD_KEYS, BAD_KEY_INDEX, UNKNOWN_INDEX, BAD_COUNT, HIGHER_TIERS, WRONG_SIZE}
#deckData [%id%] : %count%
static func verifyDeck(deckData) -> int:
	var numCards = 20
	var numSameCards = 4
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
		if count < 1 or count > numSameCards:
			return DECK_VALIDITY_TYPE.BAD_COUNT
			
		#CHECKS IF THE DECK ONLY USES TIER 1 CARDS
		if ListOfCards.getCard(key).tier > 1:
			return DECK_VALIDITY_TYPE.HIGHER_TIERS
			
		total += count
		
	#CHECKS IF THERE ARE THE RIGHT NUMBER OF TOTAL CARDS
	if total != numCards:
		return DECK_VALIDITY_TYPE.WRONG_SIZE
		
	return DECK_VALIDITY_TYPE.VALID

