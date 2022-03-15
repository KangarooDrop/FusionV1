

class_name Player

var fallingTextScene = preload("res://Scenes/UI/FallingText.tscn")

var life = -1
var armour = -1
var UUID = randi()

var lifeNode
var armourNode
var board
var deck
var hand

var creatureNum := 5

var isOpponent = false

func _init(board, lifeNode, armourNode):
	deck = Deck.new()
	self.board = board
	self.lifeNode = lifeNode
	self.armourNode = armourNode
	setLife(30, false)
	setArmour(0, false)

func initHand(board):
	hand.initHand(board, self)

func heal(amt : int, source : CardNode):
	amt = max(amt, 0)
	addLife(amt)

func takeDamage(dmg : int, source : CardNode):
	dmg = max(dmg, 0)
	
	if armour > 0:
		var dmgNew = max(dmg - armour, 0)
		addArmour(max(-dmg, -armour))
		dmg = dmgNew
		
	if dmg > 0:
		addLife(-dmg)
	
	if life <= 0:
		board.onLoss(self)

func addLife(inc : int):
	setLife(life + inc)

func setLife(lifeNew : int, showChange = true):
	if showChange:
		if lifeNew > life:
			makeFallingText("+" + str(lifeNew - life), Color.green, lifeNode.position)
		else:
			makeFallingText(str(lifeNew - life), Color.red, lifeNode.position)
			
	life = lifeNew
	lifeNode.get_node("Label").text = "Life: " + str(life)

func addArmour(inc : int):
	setArmour(armour + inc)

func setArmour(armourNew : int, showChange = true):
	if showChange:
		if armourNew > armour:
			makeFallingText("+" + str(armourNew - armour), Color.darkgray, armourNode.position)
		else:
			makeFallingText(str(armourNew - armour), Color.black, armourNode.position)
			
	armour = armourNew
	armourNode.get_node("Label").text = ("Armour: " + str(armour) if armour > 0 else "")

func makeFallingText(text : String, color : Color, position : Vector2):
	var ft = fallingTextScene.instance()
	board.add_child(ft)
	var labelSize = lifeNode.get_node("Label").get_minimum_size()
	ft.position = position + Vector2(labelSize.x - 4, labelSize.y / 2)
	ft.get_node("Label").text = text
	ft.get_node("Label").set("custom_colors/font_color", color)
