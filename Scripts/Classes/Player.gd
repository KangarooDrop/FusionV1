

class_name Player

var fallingTextScene = preload("res://Scenes/UI/FallingText.tscn")

var life = -1
var UUID = randi()

var lifeNode
var board
var deck
var hand

var creatureNum := 5

var isOpponent = false

func _init(cardList, board, lifeNode):
	deck = Deck.new(cardList)
	self.board = board
	self.lifeNode = lifeNode
	setLife(30, false)

func initHand(board):
	hand.initHand(board, self)

func heal(amt : int, source : CardNode):
	amt = max(amt, 0)
	addLife(amt)

func takeDamage(dmg : int, source : CardNode):
	dmg = max(dmg, 0)
	addLife(-dmg)
	
	if life <= 0:
		board.onLoss(self)

func addLife(inc : int):
	setLife(life + inc)

func setLife(lifeNew : int, showChange = true):
	if showChange:
		if lifeNew > life:
			makeFallingText("+" + str(lifeNew - life), Color.green)
		else:
			makeFallingText(str(lifeNew - life), Color.red)
			
	life = lifeNew
	lifeNode.get_node("Label").text = "Life: " + str(life)

func makeFallingText(text : String, color : Color):
	var ft = fallingTextScene.instance()
	board.add_child(ft)
	var labelSize = lifeNode.get_node("Label").get_minimum_size()
	ft.position = lifeNode.position + Vector2(labelSize.x - 4, labelSize.y / 2)
	ft.get_node("Label").text = text
	ft.get_node("Label").set("custom_colors/font_color", color)
