extends Node2D

class_name HandNode

var cardSlot = preload("res://Scenes/CardSlot.tscn")
var cardNode = preload("res://Scenes/CardNode.tscn")

var player
var board

var deck
var drawingNode
var drawingSlot
var drawTimer = 0
var drawMaxTime = 0.25
var drawQueue : Array

var cardNodes : Array
var cardSlotNodes : Array

export var handSize := 5
export var isOpponent = false
export var handVisible := true

func initHand(board, player):
	self.board = board
	self.player = player
	for i in range(handSize + (0 if board.activePlayer == player else 1)):
		addCard(player.deck.pop())
	
func centerCards(cardWidth, cardDists):
	Board.centerNodes(cardNodes, Vector2(), cardWidth, cardDists)
	Board.centerNodes(cardSlotNodes, Vector2(), cardWidth, cardDists)

func _physics_process(delta):
	if drawQueue.size() > 0:
		if drawingNode == null:
			var slotInst = cardSlot.instance()
			slotInst.currentZone = CardSlot.ZONES.HAND
			slotInst.board = board
			slotInst.isOpponent = isOpponent
			slotInst.playerID = player.UUID
			add_child(slotInst)
			cardSlotNodes.append(slotInst)
			
			var cardInst = cardNode.instance()
			cardInst.card = drawQueue[0]
			cardInst.cardVisible = false
			if handVisible:
				cardInst.flip()
			cardInst.playerID = player.UUID
			add_child(cardInst)
			cardNodes.append(cardInst)
			
			slotInst.cardNode = cardInst
			
			centerCards(board.cardWidth, board.cardDists)
			cardInst.global_position = deck.global_position
			
			drawingSlot = slotInst
			drawingNode = cardInst
		else:
			drawTimer += delta
			drawingNode.global_position = lerp(deck.global_position, drawingSlot.global_position, drawTimer / drawMaxTime)
			if drawTimer >= drawMaxTime:
				drawTimer = 0
				drawingNode.global_position = drawingSlot.global_position
				drawingNode = null
				drawQueue.remove(0)

func drawCard():
	var card = player.deck.pop()
	if player.deck.cards.size() <= 0 and is_instance_valid(deck.cardNode):
		deck.cardNode.queue_free()
		deck.cardNode = null
	if card != null:
		addCard(card)

func addCard(card : Card):
	if card != null:
		if Settings.playAnimations:
			drawQueue.append(card)
		else:
			var slotInst = cardSlot.instance()
			slotInst.currentZone = CardSlot.ZONES.HAND
			slotInst.board = board
			slotInst.isOpponent = isOpponent
			slotInst.playerID = player.UUID
			add_child(slotInst)
			cardSlotNodes.append(slotInst)
			
			var cardInst = cardNode.instance()
			cardInst.card = card
			cardInst.setCardVisible(true)
			cardInst.playerID = player.UUID
			add_child(cardInst)
			cardNodes.append(cardInst)
			
			slotInst.cardNode = cardInst
			
			centerCards(board.cardWidth, board.cardDists)
