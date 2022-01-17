
extends Node2D

class_name BoardMP

var cardSlot = preload("res://Scenes/CardSlot.tscn")
var cardNode = preload("res://Scenes/CardNode.tscn")
onready var cardWidth = ListOfCards.cardBackground.get_width()
onready var cardHeight = ListOfCards.cardBackground.get_height()

var cardDists = 16

var enchantNumShared := 1

var enchants : Dictionary
var creatures : Dictionary
var graves : Dictionary
var decks : Dictionary
var fusionHolders : Dictionary

var boardSlots : Array

var players : Array
var activePlayer
var playedThisTurn = false

onready var enchantHolder = $EnchantHolder
onready var creatures_A_Holder = $Creatures_A
onready var creatures_B_Holder = $Creatures_B
onready var graveHolder = $GraveHolder
onready var deckHolder = $DeckHolder
onready var card_A_Holder = $Card_A_Holder
onready var card_B_Holder = $Card_B_Holder
onready var fusion_A_Holder = $Fusion_A_Holder
onready var fusion_B_Holder = $Fusion_B_Holder

var cardsHolding : Array
var selectedCard : CardSlot
var selectRotTimer = 0

var fuseQueue : Array
var fusing = false
var fuseEndSlot = null
var fuseEndPos = null
var fuseStartPos = null
var fuseTimer = 0
var fuseMaxTime = 0.1
var fuseReturnTimer = 0
var fuseReturnMaxTime = 0.3
var fuseWaiting = false
var fuseWaitTimer = 0
var fuseWaitMaxTime = 0.2

func _ready():
	var gameSeed = OS.get_system_time_msecs()
	print("current game seed is ", gameSeed)
	seed(gameSeed)
	
	
	var cardList : Array
	for i in range(20):
		var cardID = randi() % 7
		cardList.append(ListOfCards.getCard(21 if cardID == 6 else cardID))
	
	var player_A = Player.new(cardList)
	player_A.deck.shuffle()
	var player_B = Player.new([])
	player_B.isOpponent = true
	players.append(player_A)
	players.append(player_B)
	enchants[player_A.UUID] = []
	enchants[player_B.UUID] = []
	enchants[-1] = []
	creatures[player_A.UUID] = []
	creatures[player_B.UUID] = []
	activePlayer = player_A if Server.host else player_B
	
	initZones()
	initHands()
	
	print("Fetching opponent's deck list")
	Server.fetchDeck(get_instance_id())

var deckDataSet = false
var readyToStart = false

func setDeckData(data):
	players[1].deck.deserialize(data)
	
	print("Sending game start signal to opponent")
	Server.onGameStart()
	deckDataSet = true

func onGameStart():
	readyToStart = true

func _physics_process(delta):
	if readyToStart and deckDataSet:
		readyToStart = false
		deckDataSet = false
		players[0].initHand(self)
		players[1].initHand(self)
		
		
	if is_instance_valid(selectedCard):
		selectRotTimer += delta
		selectedCard.cardNode.rotation = sin(selectRotTimer * 1.5) * PI / 32
	
	if fuseQueue.size() > 0:
		if fuseWaiting:
			fuseWaitTimer += delta
			if fuseWaitTimer >= fuseWaitMaxTime:
				fuseWaiting = false
		else:
			if fuseQueue.size() > 1:
				if not fusing:
					fusing = true
					fuseStartPos = fuseQueue[1].position
					fuseEndPos = fuseQueue[0].position
				if fusing:
					fuseTimer += delta
					if fuseTimer >= fuseMaxTime:
						fuseTimer = 0
						fusing = false
						fuseQueue[0].card = Card.fusePair(fuseQueue[0].card, fuseQueue[1].card)
						fuseQueue[0].setCardVisible(true)
						fuseQueue[1].queue_free()
						fuseQueue.remove(1)
						fuseWaiting = true
						fuseWaitTimer = 0
						if fuseQueue.size() == 1:
							fuseStartPos = fuseQueue[0].global_position
							fuseReturnTimer = 0
					else:
						fuseQueue[1].position = lerp(fuseStartPos, fuseEndPos, fuseTimer / fuseMaxTime)
			elif fuseQueue.size() == 1:
				fuseReturnTimer += delta
				fuseQueue[0].global_position = lerp(fuseStartPos, fuseEndSlot.global_position, fuseReturnTimer / fuseReturnMaxTime)
				if fuseReturnTimer >= fuseReturnMaxTime:
					var cardNode = fuseQueue[0]
					fuseEndSlot.cardNode = fuseQueue[0]
					cardNode.slot = fuseEndSlot
					cardNode.get_parent().remove_child(cardNode)
					creatures_A_Holder.add_child(cardNode)
					cardNode.global_position = fuseEndSlot.global_position
					fuseQueue = []
					cardNode.card.playerID = fuseEndSlot.playerID
					cardNode.card.onEnter(self)
	
	if hoveringOn != null:
		if not shownHover:
			hoverTimer += delta
			if hoverTimer > hoverMaxTime * (0.2 if hoveringOn.currentZone == CardSlot.ZONES.DECK else 1):
				shownHover = true
				if hoveringOn.currentZone == CardSlot.ZONES.DECK:
					var numCards = players[1 if hoveringOn.isOpponent else 0].deck.cards.size()
					var string = ""
					if numCards == 1:
						string = "There is currently 1 card in this deck"
					else:
						string = "There are currently " + str(numCards) + " cards in this deck"
					print(string)
				elif is_instance_valid(hoveringOn.cardNode) and hoveringOn.cardNode.cardVisible and hoveringOn.cardNode.card != null:
					print("This card is ", hoveringOn.cardNode.card.name)

func initZones():
	var cardInst = null
	#	SHARED SLOTS	#
	for i in range(enchantNumShared):
		cardInst = cardSlot.instance()
		cardInst.currentZone = CardSlot.ZONES.ENCHANTMENT
		cardInst.board = self
		enchantHolder.add_child(cardInst)
		enchants[-1].append(cardInst)
		boardSlots.append(cardInst)
	centerNodes(enchants[-1], Vector2(), cardWidth, cardDists)
	
	#	PLAYER 1 SLOTS  	#
	var p = players[0]
	for i in range(p.enchantNum):
		cardInst = cardSlot.instance()
		cardInst.currentZone = CardSlot.ZONES.ENCHANTMENT
		cardInst.board = self
		cardInst.playerID = p.UUID
		enchantHolder.add_child(cardInst)
		enchants[p.UUID].append(cardInst)
		boardSlots.append(cardInst)
	centerNodes(enchants[p.UUID], Vector2(0, cardHeight + cardDists), cardWidth, cardDists)
	
	for i in range(p.creatureNum):
		cardInst = cardSlot.instance()
		cardInst.currentZone = CardSlot.ZONES.CREATURE
		cardInst.board = self
		cardInst.playerID = p.UUID
		creatures_A_Holder.add_child(cardInst)
		creatures[p.UUID].append(cardInst)
		boardSlots.append(cardInst)
	centerNodes(creatures[p.UUID], Vector2(), cardWidth, cardDists)
	
	cardInst = cardSlot.instance()
	cardInst.currentZone = CardSlot.ZONES.GRAVE
	cardInst.board = self
	cardInst.playerID = p.UUID
	graveHolder.add_child(cardInst)
	cardInst.position = Vector2(0, cardHeight + cardDists)
	
	cardInst = cardSlot.instance()
	cardInst.currentZone = CardSlot.ZONES.DECK
	cardInst.board = self
	cardInst.playerID = p.UUID
	deckHolder.add_child(cardInst)
	cardInst.position = Vector2(0, cardHeight + cardDists)
	var cardNodeInst = cardNode.instance()
	cardNodeInst.card = ListOfCards.getCard(0)
	cardNodeInst.cardVisible = false
	cardNodeInst.playerID = p.UUID
	cardInst.add_child(cardNodeInst)
	cardInst.cardNode = cardNodeInst
	cardNodeInst.position = Vector2()
	decks[p.UUID] = cardInst
	
	fusionHolders[p.UUID] = fusion_A_Holder
	
	
	#	PLAYER 2 SLOTS  	#
	p = players[1]
	for i in range(p.enchantNum):
		cardInst = cardSlot.instance()
		cardInst.isOpponent = true
		cardInst.currentZone = CardSlot.ZONES.ENCHANTMENT
		cardInst.board = self
		cardInst.playerID = p.UUID
		enchantHolder.add_child(cardInst)
		enchants[p.UUID].append(cardInst)
		boardSlots.append(cardInst)
	centerNodes(enchants[p.UUID], Vector2(0, -cardHeight - cardDists), cardWidth, cardDists)
	
	for i in range(p.creatureNum):
		cardInst = cardSlot.instance()
		cardInst.isOpponent = true
		cardInst.currentZone = CardSlot.ZONES.CREATURE
		cardInst.board = self
		cardInst.playerID = p.UUID
		creatures_B_Holder.add_child(cardInst)
		creatures[p.UUID].append(cardInst)
		boardSlots.append(cardInst)
	centerNodes(creatures[p.UUID], Vector2(), cardWidth, cardDists)
	
	cardInst = cardSlot.instance()
	cardInst.currentZone = CardSlot.ZONES.GRAVE
	cardInst.isOpponent = true
	cardInst.board = self
	cardInst.playerID = p.UUID
	graveHolder.add_child(cardInst)
	cardInst.position = Vector2(0, -cardHeight - cardDists)
	
	cardInst = cardSlot.instance()
	cardInst.currentZone = CardSlot.ZONES.DECK
	cardInst.isOpponent = true
	cardInst.board = self
	cardInst.playerID = p.UUID
	deckHolder.add_child(cardInst)
	cardInst.position = Vector2(0, -cardHeight - cardDists)
	cardNodeInst = cardNode.instance()
	cardNodeInst.card = ListOfCards.getCard(0)
	cardNodeInst.cardVisible = false
	cardNodeInst.playerID = p.UUID
	cardInst.add_child(cardNodeInst)
	cardInst.cardNode = cardNodeInst
	cardNodeInst.position = Vector2()
	decks[p.UUID] = cardInst
		
	fusionHolders[p.UUID] = fusion_B_Holder
	
		
func initHands():
	$HealthNode.player = players[0]
	$HealthNode2.player = players[1]
	players[0].hand = card_A_Holder
	#players[0].initHand(self)
	players[1].hand = card_B_Holder
	#players[1].initHand(self)
	players[0].hand.deck = decks[players[0].UUID]
	players[1].hand.deck = decks[players[1].UUID]
				
static func centerNodes(nodes : Array, position : Vector2, cardWidth : int, cardDists : int):
	for i in range(nodes.size()):
		nodes[i].position = position + Vector2(-(nodes.size() - 1) / 2.0 * (cardWidth + cardDists) + (cardWidth + cardDists) * i, 0)
		
		
func slotClickedServer(isOpponent : bool, slotZone : int, slotID : int, button_index : int):
	
	var playerIndex = 0 if isOpponent else 1
	var parent
	match slotZone:
		CardSlot.ZONES.NONE:
			parent = null
		CardSlot.ZONES.HAND:
			parent = players[playerIndex].hand
		CardSlot.ZONES.ENCHANTMENT:
			parent = enchantHolder
		CardSlot.ZONES.CREATURE:
			if playerIndex == 0:
				parent = creatures_A_Holder
			else:
				parent = creatures_B_Holder
		CardSlot.ZONES.GRAVE:
			parent = graveHolder
		CardSlot.ZONES.DECK:
			parent = deckHolder
	
	print("SLOT CLICKED ", parent.name, "  ", slotID, "  ", isOpponent)
	
	slotClicked(parent.get_child(slotID), button_index, true)
		
var hoverTimer = 0
var hoverMaxTime = 1
var hoveringOn = null
var shownHover = false
		
func onSlotEnter(slot : CardSlot):
	hoveringOn = slot
	hoverTimer = 0
	shownHover = false
		
func onSlotExit(slot : CardSlot):
	hoveringOn = null
	shownHover = false
		
func slotClicked(slot : CardSlot, button_index : int, fromServer = false):
	if not fromServer:
		Server.slotClicked(slot.isOpponent, slot.currentZone, slot.get_index(), button_index)
	
	
	if button_index == 1:
		if slot.playerID == activePlayer.UUID or slot.playerID == -1:
			if slot.currentZone == CardSlot.ZONES.HAND:
				#ADDING CARDS TO THE FUSION LIST
				if is_instance_valid(slot.cardNode) and not playedThisTurn:
					if cardsHolding.has(slot):
						cardsHolding.erase(slot)
						slot.position.y += cardDists
						slot.cardNode.position.y = slot.position.y
					else:
						if cardsHolding.size() < 2:
							cardsHolding.append(slot)
							slot.position.y -= cardDists
							slot.cardNode.position.y = slot.position.y
			elif slot.currentZone == CardSlot.ZONES.CREATURE:
				if cardsHolding.size() > 0:
					#PUTTING A CREATURE ONTO THE FIELD
					var endsCreature = false
					
					var cardList = []
					if is_instance_valid(slot.cardNode):
						cardList.append(slot.cardNode.card)
					for c in cardsHolding:
						cardList.append(c.cardNode.card)
					var newCard = Card.fuseCards(cardList)
					endsCreature = newCard.cardType == Card.CARD_TYPE.Creature
					
					if endsCreature:
						
						if Settings.playAnimations:
						
							if is_instance_valid(slot.cardNode):
								cardsHolding.insert(0, slot)
								
							while cardsHolding.size() > 0:
								var c = cardsHolding[0]
								var cardNode = c.cardNode
								cardNode.setCardVisible(true)
								cardsHolding.erase(c)
								fuseQueue.append(cardNode)
								cardNode.get_parent().remove_child(cardNode)
								fusionHolders[slot.playerID].add_child(cardNode)
								cardNode.position = Vector2()
								c.cardNode = null
								card_A_Holder.cardNodes.erase(cardNode)
								card_B_Holder.cardNodes.erase(cardNode)
								if c.currentZone == CardSlot.ZONES.HAND:
									card_A_Holder.cardSlotNodes.erase(c)
									card_B_Holder.cardSlotNodes.erase(c)
									c.queue_free()
							
							fuseStartPos = fuseQueue[0].global_position
							fuseEndSlot = slot
							fuseTimer = 0
							fuseReturnTimer = 0
							
							
							card_A_Holder.centerCards(cardWidth, cardDists)
							card_B_Holder.centerCards(cardWidth, cardDists)
							centerNodes(fusion_A_Holder.get_children(), Vector2(), cardWidth, cardDists)
							centerNodes(fusion_B_Holder.get_children(), Vector2(), cardWidth, cardDists)
							
							fuseWaiting = true
							fuseWaitTimer = 0
							playedThisTurn = true
						else:

							while cardsHolding.size() > 0:
								var c = cardsHolding[0]
								cardsHolding.remove(0)
								var cardNode = c.cardNode
								cardNode.get_parent().remove_child(cardNode)
								card_A_Holder.cardNodes.erase(cardNode)
								card_B_Holder.cardNodes.erase(cardNode)
								if c.currentZone == CardSlot.ZONES.HAND:
									card_A_Holder.cardSlotNodes.erase(c)
									card_B_Holder.cardSlotNodes.erase(c)
									c.queue_free()
									
							var cardPlacing = cardNode.instance()
							newCard.playerID = slot.playerID
							cardPlacing.card = newCard
							creatures_A_Holder.add_child(cardPlacing)
							cardPlacing.global_position = slot.global_position
							if is_instance_valid(slot.cardNode):
								slot.cardNode.queue_free()
							slot.cardNode = cardPlacing
							cardPlacing.slot = slot
							
							newCard.onEnter(self)
							playedThisTurn = true
							
							card_A_Holder.centerCards(cardWidth, cardDists)
							card_B_Holder.centerCards(cardWidth, cardDists)
							
				else:
					#ATTACKING
					if is_instance_valid(slot) and selectedCard == slot:
						selectedCard.cardNode.rotation = 0
						selectRotTimer = 0
						selectedCard = null
					else:
						if is_instance_valid(slot.cardNode) and not slot.cardNode.card.hasAttacked:
							if is_instance_valid(selectedCard):
								selectedCard.cardNode.rotation = 0
							selectRotTimer = 0
							selectedCard = slot
						
			elif slot.currentZone == CardSlot.ZONES.ENCHANTMENT:
				if cardsHolding.size() > 0:
					#PUTTING A CREATURE ONTO THE FIELD
					var endsEnchant = false
					
					var cardList = []
					if is_instance_valid(slot.cardNode):
						cardList.append(slot.cardNode.card)
					for c in cardsHolding:
						cardList.append(c.cardNode.card)
					var newCard = Card.fuseCards(cardList)
					endsEnchant = newCard.cardType == Card.CARD_TYPE.Enchantment
					
					if endsEnchant:
						if is_instance_valid(slot.cardNode):
							cardsHolding.insert(0, slot)
							
						for c in cardsHolding:
							card_A_Holder.cardNodes.erase(c.cardNode)
							card_B_Holder.cardNodes.erase(c.cardNode)
							c.cardNode.queue_free()
							
							if c.currentZone == CardSlot.ZONES.HAND:
								card_A_Holder.cardSlotNodes.erase(c)
								card_B_Holder.cardSlotNodes.erase(c)
								c.queue_free()
						cardsHolding.clear()
						
						var cardPlacing = cardNode.instance()
						cardPlacing.card = newCard
						creatures_A_Holder.add_child(cardPlacing)
						cardPlacing.global_position = slot.global_position
						slot.cardNode = cardPlacing
						cardPlacing.slot = slot
						
						card_A_Holder.centerCards(cardWidth, cardDists)
						card_B_Holder.centerCards(cardWidth, cardDists)
						
						playedThisTurn = true
				
			elif slot.currentZone == CardSlot.ZONES.GRAVE:
				pass
			else:
				pass
		else:
			if slot.currentZone == CardSlot.ZONES.CREATURE:
				if is_instance_valid(slot.cardNode) and is_instance_valid(selectedCard):
					selectedCard.cardNode.card.onAttack(slot, self)
					slot.cardNode.card.onBeingAttacked(selectedCard, self)
					selectedCard.cardNode.attack(slot.global_position + (selectedCard.cardNode.global_position - slot.global_position).normalized() * cardHeight, slot)
					
					
					if is_instance_valid(selectedCard.cardNode):
						selectedCard.cardNode.rotation = 0
						selectRotTimer = 0
						
					selectedCard = null
				elif is_instance_valid(selectedCard):
#					var foundCreature = false
#					for s in creatures[slot.playerID]:
#						if is_instance_valid(s.cardNode):
#							foundCreature = true
#					if not foundCreature:
					for p in players:
						if p.UUID == slot.playerID:
							selectedCard.cardNode.card.onAttack(null, self)
							selectedCard.cardNode.attack(slot.global_position + (selectedCard.cardNode.global_position - slot.global_position).normalized() * cardHeight, slot)
							selectedCard.cardNode.rotation = 0
							selectRotTimer = 0
							selectedCard = null

func isMyTurn() -> bool:
	return players[0] == activePlayer

func _input(event):
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.scancode == KEY_Q:
			if isMyTurn():
				var waiting = true
				while waiting:
					var attacking = false
					for slot in creatures[activePlayer.UUID]:
						if is_instance_valid(slot.cardNode) and slot.cardNode.attacking:
							attacking = true
						if not attacking:
							waiting = false
							
					for p in players:
						if p.hand.drawQueue.size() > 0:
							waiting = true
							
					if fuseQueue.size() > 0:
						waiting = true
							
					yield(get_tree().create_timer(0.1), "timeout")
				nextTurn()
				Server.onNextTurn()
			
			
func nextTurn():
	#Engine.time_scale = 0.1
	print("NEXT TURN")
	while cardsHolding.size() > 0:
		cardsHolding[0].position.y += cardDists
		cardsHolding[0].cardNode.position.y = cardsHolding[0].position.y
		cardsHolding.remove(0)
	if is_instance_valid(selectedCard):
		selectedCard.cardNode.rotation = 0
		
	######################	ON END OF TURN EFFECTS
	for slot in boardSlots:
		if is_instance_valid(slot.cardNode):
			slot.cardNode.card.onEndOfTurn(self)
	######################
		
	playedThisTurn = false
	activePlayer = players[(players.find(activePlayer) + 1) % players.size()]
	activePlayer.hand.drawCard()
		
	######################	ON START OF TURN EFFECTS
	var slotsToCheck = []
	for slot in boardSlots:
		if is_instance_valid(slot.cardNode):
			slotsToCheck.append(slot)
	for slot in slotsToCheck:
			slot.cardNode.card.onStartOfTurn(self)
	######################

