
extends Node2D

class_name Player

var life = 20
var UUID = randi()

var board
var deck
var hand

var enchantNum := 2
var creatureNum := 5

var isOpponent = false

func _init(cardList, board):
	deck = Deck.new(cardList)
	self.board = board

func initHand(board):
	hand.initHand(board, self)

func takeDamage(dmg : int, source : CardNode):
	life -= dmg
	
	if life <= 0:
		board.onLoss(self)
