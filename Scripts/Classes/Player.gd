

class_name Player

var fallingTextScene = preload("res://Scenes/UI/FallingText.tscn")

var life = -1
var armour = -1
var UUID = randi()

var lifeNode
var armourNode
var deck
var hand

var creatureNum := 5

var isOpponent = false
var isPractice = false

var drawDamage = 1

func _init(lifeNode, armourNode):
	deck = Deck.new()
	self.lifeNode = lifeNode
	self.armourNode = armourNode
	setLife(30, false)
	setArmour(0, false)

func initHand():
	hand.initHand(self)

func heal(amt : int, source):
	amt = max(amt, 0)
	addLife(amt)

func takeDamage(dmg : int, source):
	dmg = max(dmg, 0)
	
	if armour > 0:
		var dmgNew = max(dmg - armour, 0)
		addArmour(max(-dmg, -armour))
		dmg = dmgNew
		
	if dmg > 0:
		addLife(-dmg)
		addToFlag(DAMAGE_TAKEN, dmg)
	
	if life <= 0:
		NodeLoc.getBoard().onLoss(self)

func addLife(inc : int):
	setLife(life + inc)

func setLife(lifeNew : int, showChange = true):
	if showChange:
		if lifeNew > life:
			makeFallingText("+" + str(lifeNew - life), Color.green, lifeNode.global_position)
		else:
			makeFallingText(str(lifeNew - life), Color.red, lifeNode.global_position)
			
	life = lifeNew
	lifeNode.get_node("Label").text = "Life: " + str(life)

func addArmour(inc : int):
	setArmour(armour + inc)

func setArmour(armourNew : int, showChange = true):
	if showChange:
		if armourNew > armour:
			makeFallingText("+" + str(armourNew - armour), Color.darkgray, armourNode.global_position)
		else:
			makeFallingText(str(armourNew - armour), Color.black, armourNode.global_position)
			
	armour = armourNew
	armourNode.get_node("Label").text = ("Armour: " + str(armour) if armour > 0 else "")

var ftData := []
func makeFallingText(text : String, color : Color, global_position : Vector2):
	ftData.append([text, color, global_position])

func _physics_process(delta):
	for i in range(10):
		if ftData.size() > 0:
			print("hee hee")
			var ft = fallingTextScene.instance()
			NodeLoc.getBoard().add_child(ft)
			var labelSize = lifeNode.get_node("Label").get_minimum_size()
			ft.get_node("Label").text = ftData[0][0]
			ft.get_node("Label").set("custom_colors/font_color", ftData[0][1])
			ft.global_position = ftData[0][2] + Vector2(labelSize.x - 4, labelSize.y / 2)
			ftData.remove(0)

const CREATURES_ATTACKED = 					"creatures_attacked"
const DAMAGE_TAKEN = 						"damage_taken"
const CARDS_DRAWN_DECK = 					"cards_drawn"
const CARDS_ADDED = 						"cards_added"
const CARDS_PLAYED = 						"cards_played"
const MANA_SPENT = 							"mana_spent"

const defaultFlag = {"yourLastTurn":0, "lastTurn":0, "currentTurn":0, "total":0}
var flags : Dictionary = \
{
	CREATURES_ATTACKED:				defaultFlag.duplicate(),
	DAMAGE_TAKEN:					defaultFlag.duplicate(),
	CARDS_DRAWN_DECK: 				defaultFlag.duplicate(),
	CARDS_ADDED: 					defaultFlag.duplicate(),
	CARDS_PLAYED:					defaultFlag.duplicate(),
	MANA_SPENT:						defaultFlag.duplicate()
}


func onStartOfTurn():
	for f in flags:
		flags[f].yourLastTurn = flags[f].lastTurn
		flags[f].lastTurn = flags[f].currentTurn
		flags[f].currentTurn = 0

func addToFlag(flag : String, inc : int):
	if flags.has(flag):
		flags[flag].currentTurn += inc
		flags[flag].total += inc

func getFlag(flag : String) -> Dictionary:
	return flags[flag]

func printFlags():
	for k in flags.keys():
		print(k, ": ", getFlag(k))
