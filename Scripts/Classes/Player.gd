
extends Node2D

class_name Player

var life = 20
var UUID = randi()

var board
var deck
var hand

var enchantNum := 2
var creatureNum := 5

func _init():
	var cardList_A : Array
	for i in range(20):
		var cardID = randi() % 7
		cardList_A.append(ListOfCards.getCard(21 if cardID == 6 else cardID))
		
	deck = Deck.new(cardList_A)

func initHand(board):
	hand.initHand(board, self)

func takeDamage(dmg : int, source : CardNode):
	life -= dmg
