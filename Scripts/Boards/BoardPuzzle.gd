
extends Node2D

class_name BoardPuzzle

var puzzleData = null

var deadPlayers = []

var popupUI = preload("res://Scenes/UI/PopupUI.tscn")
var cardSlot = preload("res://Scenes/CardSlot.tscn")
var cardNode = preload("res://Scenes/CardNode.tscn")
onready var cardWidth = ListOfCards.cardBackground.get_width()
onready var cardHeight = ListOfCards.cardBackground.get_height()
var hoverScene = preload("res://Scenes/UI/Hover.tscn")
var fadingScene = preload("res://Scenes/UI/FadingNode.tscn")

var cardDists = 16

var timerPlayer : int = -1
var timers : Dictionary
var delayedAbilityCards : Dictionary
var creatures : Dictionary
var decks : Dictionary
var graves : Dictionary
var graveCards : Dictionary
var graveDisplays : Dictionary

var boardSlots : Array

var typeDisplay

var players : Array
var activePlayer := -1
var cardsPerTurnMax := 2
var cardsPerTurn := cardsPerTurnMax
var cardsPlayed = 0

var shakeMaxTime = 0.5
var shakeAmount = 0.8
var shakeFrequency = 6
var cardsShaking := {}

onready var creatures_A_Holder = $Creatures_A
onready var creatures_B_Holder = $Creatures_B
onready var deckHolder = $DeckHolder
onready var card_A_Holder = $Hand_A
onready var card_B_Holder = $Hand_B

var cardsHolding : Array
var selectedCard : CardSlot
var highlightedSlots := []

var actionQueue : Array

var millQueue : Array
var millNode
var millWaitTimer = 0
var millWaitMaxTime = 0.5



var isEntering = false
var cardNodesFusing : Array
var fusing = false
var fuseEndSlot = null
var fuseEndPos = null
var fuseStartPos = null

var fuseTimer = 0
var fuseMaxTime = 0.1
var fuseSpinTimer = 0
var fuseSpinMaxTime = 0.75
var fuseRPS = 2
var fuseSpinWaitTimer = 0
var fuseSpinWaitMaxTime = 0.501

var fuseReturnTimer = 0
var fuseReturnMaxTime = 0.3

var fuseWaiting = false
var fuseWaitTimer = 0
var fuseWaitMaxTime = 0.3

var fusingToHandPlayer
var isFusingToHand = false



var gameStarted = false
var gameOver = false

var abilityStack : AbilityStack = AbilityStack.new()
var currentAbility = null
var waitingAbilities := []

var gameSeed = -1

var rightClickQueue := []

var selectingSlot = false
var selectingType = false
var selectingSource = null
var selectingUUID = -1

var stackMaxTime = 1
var stackTimer = 0

var cardsMovingCard := []
var cardsMovingAbility := []
var cardsMovingSlot := []

func _ready():
	print("-".repeat(30))
	
	BackgroundFusion.stop()
	MusicManager.playBoardMusic()
	
	setOwnUsername()
	
	players.append(Player.new($HealthNode, $ArmourNode))
	creatures[players[0].UUID] = []
	timers[players[0].UUID] = $TurnTimer_A
	$TurnTimer_A.connect("onTurnTimerEnd", self, "onTurnTimerEnd")
	$TurnTimer_A.connect("onGameTimerEnd", self, "onGameTimerEnd")
	var dc = ListOfCards.getCard(0)
	dc.playerID = players[0].UUID
	dc.ownerID = players[0].UUID
	delayedAbilityCards[players[0].UUID] = dc
	
	players.append(Player.new($HealthNode2, $ArmourNode2))
	players[1].isOpponent = true
	players[1].isPractice = Settings.gameMode == Settings.GAME_MODE.PRACTICE
	creatures[players[1].UUID] = []
	timers[players[1].UUID] = $TurnTimer_B
	dc = ListOfCards.getCard(0)
	dc.playerID = players[1].UUID
	dc.ownerID = players[1].UUID
	delayedAbilityCards[players[1].UUID] = dc
	
	initZones()
	initHands()
	
	activePlayer = 0
	
	gameSeed = OS.get_system_time_msecs()
	print("current game seed is ", gameSeed)
	seed(gameSeed)
	
	initCardsLeftIndicator()
	setTurnText()
	
	if puzzleData == null:
		puzzleData = FileIO.readJSON("res://puzzles/bak.json")
	deserialize(puzzleData)
	
	gameStarted = true

func initCardsLeftIndicator():
	if activePlayer == 0:
		$CardsLeftIndicator_A.setCardData(cardsPerTurn, 0, 0)
		$CardsLeftIndicator_B.setCardData(0, 0, cardsPerTurn)
	else:
		$CardsLeftIndicator_A.setCardData(0, 0, cardsPerTurn)
		$CardsLeftIndicator_B.setCardData(cardsPerTurn, 0, 0)

func setTurnText():
	if activePlayer == 0:
		$TI/Label.text = "Your\nTurn"
		if gameStarted:
			$EndTurnButton.visible = true
	else:
		$TI/Label.text = "Opponent\nTurn"
		$EndTurnButton.visible = false

func getCanFight() -> bool:
	return (abilityStack.size() == 0 or abilityStack.getFront()["canAttack"]) and cardNodesFusing.size() == 0 and millQueue.size() == 0 and not isDrawing()

func puzzleRestart():
	var root = get_node("/root")
	var mainOld = root.get_node("main")
	var mainNew = load("res://Scenes/main.tscn").instance()
	
	mainNew.connect("BoardScriptAdded", self, "BoardScriptAdded")
	
	root.add_child(mainNew)
	get_tree().current_scene = mainNew
	
	root.remove_child(mainOld)
	mainOld.queue_free()
	
	mainNew.name = "main"

func BoardScriptAdded(board):
	board.puzzleData = puzzleData

var rotTimer = 0
var rotAngle = PI / 2
var rotFreq = 1

var practiceWaiting = false

func _physics_process(delta):
	if not gameOver:
		for p in players:
			p._physics_process(delta)
	
	if not gameOver and deadPlayers.size() > 0:
		gameOver = true
		
		for k in timers.keys():
			timers[k].stopTurnTimer()
		
		var out
		if deadPlayers.size() == 1:
			if deadPlayers[0] == players[0]:
				out = 1
			elif deadPlayers[0] == players[1]:
				out = 0
		elif deadPlayers.size() == players.size():
			out = 2
		get_node("/root/main/CenterControl/WinLose").showWinLose(out)
		deadPlayers.clear()
		
		yield(get_tree().create_timer(2.5), "timeout")
		if out == 0:
			print("A winner is you!")
		elif out == 1 or out == 2:
			puzzleRestart()
			
	
	if Settings.gameMode == Settings.GAME_MODE.PRACTICE or Settings.gameMode == Settings.GAME_MODE.PUZZLE:
		if not practiceWaiting and activePlayer != 0 and gameStarted and not getWaiting():
			practiceWaiting = true
			yield(get_tree().create_timer(1), "timeout")
			if not getWaiting() and activePlayer != 0:
				nextTurn()
			practiceWaiting = false
	
	if gameStarted:
		rotAngle = PI / 32
		rotFreq = 0.2
		if isMyTurn():
			rotTimer += delta
		else:
			rotTimer = 0
		$TI.rotation = sin(2 * PI * rotTimer * rotFreq) * rotAngle
		
	if is_instance_valid(hoveringWindowSlot):
		if hoveringWindowSlot.currentZone == CardSlot.ZONES.DECK:
			var string = ""
			var p = players[1 if hoveringWindowSlot.isOpponent else 0]
			var numCards = p.deck.cards.size()
			if numCards == 0:
				string = "Take " + str(players[1 if hoveringWindowSlot.isOpponent else 0].drawDamage) + " damage on draw"
			else:
				string = str(numCards) + "/" + str(p.deck.deckSize)
			if hoveringWindow.text != string:
				hoveringWindow.visible = true
				hoveringWindow.setText(string)
	
	var dAnim = delta * Settings.animationSpeed
	
	if cardNodesFusing.size() > 0:
		if fuseWaiting:
			fuseWaitTimer += dAnim
			if fuseWaitTimer >= fuseWaitMaxTime:
				fuseWaiting = false
		else:
			if cardNodesFusing.size() > 1:
				if not fusing:
					fusing = true
					fuseStartPos = cardNodesFusing[1].position
					fuseEndPos = cardNodesFusing[0].position
				if fusing:
					fuseTimer += dAnim
					if fuseTimer < fuseMaxTime:
						fuseTimer += dAnim
						var deltaPos = cardNodesFusing[1].position
						cardNodesFusing[1].position = lerp(fuseStartPos, fuseEndPos, fuseTimer / fuseMaxTime)
						deltaPos -= cardNodesFusing[1].position
						for i in range(2, cardNodesFusing.size()):
							cardNodesFusing[i].position -= deltaPos
						
						if fuseTimer >= fuseMaxTime:
							cardNodesFusing[0].flipToSameSide()
							cardNodesFusing[1].flipToSameSide()
					
					elif fuseSpinWaitTimer < fuseSpinWaitMaxTime:
						fuseSpinWaitTimer += dAnim
						cardNodesFusing[0].position = fuseEndPos + Vector2(lerp(0, -cardWidth* 1.5, fuseSpinWaitTimer / fuseSpinWaitMaxTime), 0)
						cardNodesFusing[1].position = fuseEndPos + Vector2(lerp(0, cardWidth* 1.5, fuseSpinWaitTimer / fuseSpinWaitMaxTime), 0)
					
					elif fuseSpinTimer < fuseSpinMaxTime:
						fuseSpinTimer += dAnim
						
						var x = fuseSpinTimer / fuseSpinMaxTime
						var ss
						if x < 0.5:
							ss = 0.5 - sqrt(.25 - x*x)
						else:
							ss = 0.5 + sqrt(.25 - (x-1)*(x-1))
			
						cardNodesFusing[0].position = fuseEndPos + Vector2(lerp(-cardWidth* 1.5, 0, fuseSpinTimer / fuseSpinMaxTime), 0).rotated(fuseSpinTimer / fuseSpinMaxTime * PI * 2 * fuseRPS)
						cardNodesFusing[1].position = fuseEndPos + Vector2(lerp(cardWidth* 1.5, 0, fuseSpinTimer / fuseSpinMaxTime), 0).rotated(fuseSpinTimer / fuseSpinMaxTime * PI * 2 * fuseRPS)
						
						if fuseSpinTimer >= fuseSpinMaxTime:
							fuseTimer = 0
							fuseSpinTimer = 0
							fuseSpinWaitTimer = 0
							fusing = false
							#cardNodesFusing[0].slot = fuseEndSlot
							cardNodesFusing[0].card.fuseToSelf(cardNodesFusing[1].card)
							cardNodesFusing[0].setCardVisible(true)
							cardNodesFusing[1].queue_free()
							cardNodesFusing.remove(1)
							fuseWaiting = true
							fuseWaitTimer = 0
							if cardNodesFusing.size() == 1:
								fuseStartPos = cardNodesFusing[0].global_position
								fuseReturnTimer = 0
						
			elif cardNodesFusing.size() == 1:
				if isFusingToHand:
					fusingToHandPlayer.hand.addCardToHand([cardNodesFusing[0].card, true, true])
					fusingToHandPlayer = null
					isFusingToHand = false
					cardNodesFusing[0].queue_free()
					cardNodesFusing.clear()
					checkState()
				else:
					fuseReturnTimer += dAnim
					cardNodesFusing[0].global_position = lerp(fuseStartPos, fuseEndSlot.global_position, fuseReturnTimer / fuseReturnMaxTime)
					if fuseReturnTimer >= fuseReturnMaxTime:
						var cardNode = cardNodesFusing[0]
						cardNode.get_parent().remove_child(cardNode)
						creatures_A_Holder.add_child(cardNode)
						cardNode.global_position = fuseEndSlot.global_position
						cardNodesFusing = []
						
						var cs = getAllCards()
						if isEntering:
							for c in cs:
								if c != cardNode.card:
									c.onOtherEnter(fuseEndSlot)
							cardNode.card.onEnter(fuseEndSlot)
						else:
							for c in cs:
								if c != cardNode.card:
									c.onOtherEnterFromFusion(fuseEndSlot)
							cardNode.card.onEnterFromFusion(fuseEndSlot)
						
						checkState()
					
					
	if millQueue.size() > 0:
		if millWaitTimer == 0:
			var playerNum = -1
			for i in range(players.size()):
				if players[i].UUID == millQueue[0]:
					playerNum = i
			
			var card
			if playerNum != -1:
				card = players[playerNum].deck.pop()
				
				if players[playerNum].deck.cards.size() <= 0 and is_instance_valid(decks[players[playerNum].UUID].cardNode):
					decks[players[playerNum].UUID].cardNode.queue_free()
					decks[players[playerNum].UUID].cardNode = null
					
			else:
				millQueue.remove(0)
				print("Player ID not found for mill")
				
			if card != null:
				var cn = cardNode.instance()
				cn.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
				cn.card = card
				cn.card.cardNode = cn
				add_child(cn)
				cn.z_index += 1
				cn.global_position = decks[players[playerNum].UUID].global_position
				cn.playerID = players[playerNum].UUID
				millNode = cn
			else:
				millQueue.remove(0)
		
		if is_instance_valid(millNode):
			if millWaitTimer < millWaitMaxTime:
				millWaitTimer += dAnim
				if millWaitTimer >= millWaitMaxTime:
					for c in getAllCards():
						c.onMill(millNode.card)
					
					addCardToGrave(millNode.playerID, ListOfCards.getCard(millNode.card.UUID))
					millNode.queue_free()
					millNode = null
					millQueue.remove(0)
					millWaitTimer = 0
					checkState()
				else:
					millNode.global_position = lerp(decks[millNode.playerID].global_position, graves[millNode.playerID].global_position, millWaitTimer / millWaitMaxTime)
					
	for slot in cardsShaking.keys():
		if not is_instance_valid(slot) or not is_instance_valid(slot.cardNode):
			cardsShaking.erase(slot)
		else:
			cardsShaking[slot] -= delta
			if cardsShaking[slot] < 0:
				slot.cardNode.global_position = slot.global_position
				cardsShaking.erase(slot)
			else:
				slot.cardNode.position.x += cos((shakeMaxTime - cardsShaking[slot]) * PI * 2 * shakeFrequency) * shakeAmount
	
	if gameStarted:
		if actionQueue.size() == 0 and ((selectingUUID == players[1].UUID and Settings.gameMode == Settings.GAME_MODE.PRACTICE) or (selectingUUID == players[0].UUID and timers[selectingUUID].turnOver)):
			if selectingSlot:
				selectingSource.slotClicked(null)
			elif selectingType:
				selectingSource.onTypeButtonPressed(null, null)
		
		if not selectingSlot and not selectingType and cardNodesFusing.size() == 0 and players[0].hand.drawQueue.size() == 0 and players[0].hand.discardQueue.size() == 0 and players[1].hand.drawQueue.size() == 0 and players[1].hand.discardQueue.size() == 0 and millQueue.size() == 0:
			if abilityStack.size() > 0:
				currentAbility = abilityStack.getFront()
				
			if abilityStack.size() > 0 and not currentAbility["triggered"]:
				abilityStack.trigger(currentAbility)
				
			if abilityStack.size() > 0 and stackTimer <= 0:
				if not selectingSlot and not selectingType:
					if not waitingAbilities.has(currentAbility["source"]) or currentAbility["source"].checkWaiting():
						waitingAbilities.erase(currentAbility["source"])
						abilityStack.erase(currentAbility)
						currentAbility = null
						checkState()
				if abilityStack.size() > 0:
					stackTimer = stackMaxTime
					
			elif stackTimer > 0:
				stackTimer -= delta
				
		if (abilityStack.size() == 0 or selectingSlot) and actionQueue.size() > 0:
			if is_instance_valid(actionQueue[0][0]):
				if not (waitAttacking() or waitDrawing() or waitFusing() or waitMilling()) and (not waitAbilityStack() or selectingSlot):
					slotClicked(actionQueue[0][0], actionQueue[0][1], false)
					actionQueue.remove(0)
			else:
				actionQueue.remove(0)
	
	if rightClickQueue.size() > 0:
		clickedOff = false
		var selectedSlot = rightClickQueue[0]
		
		for i in range(1, rightClickQueue.size()):
			if not is_instance_valid(selectedSlot.cardNode) or (is_instance_valid(rightClickQueue[i].cardNode) and rightClickQueue[i].cardNode.z_index > selectedSlot.cardNode.z_index):
				selectedSlot = rightClickQueue[i]
		rightClickQueue.clear()
		
		var isSame = hoveringWindowSlot == selectedSlot
		
		if is_instance_valid(selectedSlot) and not isSame:
			if is_instance_valid(hoveringWindow):
				if hoveringWindow.close(true):
					hoveringWindowSlot = null
			if is_instance_valid(selectedSlot) and not selectedSlot.currentZone == CardSlot.ZONES.GRAVE:
				var string = null
				var pos := Vector2()
				var flipped := false
				if selectedSlot.currentZone == CardSlot.ZONES.DECK:
					var numCards = players[1 if selectedSlot.isOpponent else 0].deck.cards.size()
					string = ""
					pos = selectedSlot.global_position - Vector2(cardWidth*selectedSlot.scale.x/2, 0)
					flipped = true
				elif is_instance_valid(selectedSlot.cardNode) and selectedSlot.cardNode.cardVisible and selectedSlot.cardNode.card != null:
					string = selectedSlot.cardNode.card.getHoverData()
					pos = selectedSlot.global_position + Vector2(cardWidth*selectedSlot.scale.x/2, 0)
				
				if string != null:
					var card = null
					if is_instance_valid(selectedSlot.cardNode):
						card = selectedSlot.cardNode.card
					createHoverNode(pos, self, string, flipped, card)
					hoveringWindowSlot = selectedSlot
					if string == "":
						hoveringWindow.visible = false
			elif selectedSlot.currentZone == CardSlot.ZONES.GRAVE:
				if graveCards[selectedSlot.playerID].size() > 0:
					if selectedSlot.playerID == graveViewing:
						graveDisplays[graveViewing].visible = false
						graveViewing = -1
					elif graveCards[selectedSlot.playerID].size() > 0:
						if graveViewing != -1:
							graveDisplays[graveViewing].visible = false
						graveDisplays[selectedSlot.playerID].visible = true
						graveViewing = selectedSlot.playerID
				else:
					pass
			
		elif is_instance_valid(hoveringWindowSlot):
			if is_instance_valid(hoveringWindow):
				if hoveringWindow.close():
					hoveringWindowSlot = null
	elif clickedOff:
		clickedOff = false
		if is_instance_valid(hoveringWindow):
			if hoveringWindow.close():
				hoveringWindowSlot = null
		elif graveViewing != -1:
			graveDisplays[graveViewing].visible = false
			graveViewing = -1

var graveViewing := -1

func addCardToGrave(playerID : int, card : Card):
	if card.tier < 1:
		return
	
	var oldCard = graves[playerID].cardNode.card
	if graves[playerID].cardNode.getCardVisible():
		graves[playerID].cardNode.card.cardNode = null
		graves[playerID].cardNode.card = null
	
	card.playerID = playerID
	
	var cl = card.clone()
	cl.toughness = cl.maxToughness
	graveDisplays[playerID].addCard(cl)
	
	graveCards[playerID].append(cl)
	
	var cn = graves[playerID].cardNode
	cn.clearOverlays()
	cn.visible = true
	cn.card = cl.clone()
	cn.card.cardNode = cn
	cn.setCardVisible(true)
	
	for c in getAllCards():
		c.onGraveAdd(card)

func removeCardFromGrave(playerID : int, index : int):
	if index == graveCards[playerID].size() - 1 and graveCards[playerID].size() > 1:
		var cn = graves[playerID].cardNode
		cn.clearOverlays()
		cn.visible = true
		cn.card = graveCards[playerID][index-1].clone()
		cn.setCardVisible(true)
	
	graveCards[playerID].remove(index)
	graveDisplays[playerID].removeCard(index)
	
	if graveCards[playerID].size() == 0:
		var cn = graves[playerID].cardNode
		cn.clearOverlays()
		cn.visible = false
		cn.setCardVisible(false)
		if graveViewing == playerID:
			graveDisplays[playerID].visible = false
			graveViewing = -1

func createHoverNode(position : Vector2, parent : Node, text : String, flipped = false, card = null):
	var hoverInst = hoverScene.instance()
	hoverInst.card = card
	hoverInst.flipped = flipped
	parent.add_child(hoverInst)
	hoverInst.global_position = position
	hoverInst.setText(text)
	hoveringWindow = hoverInst

func initZones():
	
	typeDisplay = $TypeDisplay
	typeDisplay.setOptions("Choose A Creature Type", ["Fire", "Water", "Earth", "Beast", "Mech", "Necro"], [2, 3, 4, 5, 6, 7])
	typeDisplay.hideBack()
	typeDisplay.connect("onOptionPressed", self, "onTypeButtonPressed")
	typeDisplay.hide()
	
	var cardInst = null
	
	#	PLAYER 1 SLOTS  	#
	var p = players[0]
	
	for i in range(p.creatureNum):
		cardInst = cardSlot.instance()
		cardInst.currentZone = CardSlot.ZONES.CREATURE
		cardInst.playerID = p.UUID
		creatures_A_Holder.add_child(cardInst)
		cardInst.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
		creatures[p.UUID].append(cardInst)
		boardSlots.append(cardInst)
	centerNodes(creatures[p.UUID], Vector2(), cardWidth, cardDists)
	
	cardInst = cardSlot.instance()
	cardInst.currentZone = CardSlot.ZONES.DECK
	cardInst.playerID = p.UUID
	deckHolder.add_child(cardInst)
	cardInst.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
	cardInst.position = Vector2(0, cardHeight)
	var cardNodeInst = cardNode.instance()
	cardNodeInst.card = ListOfCards.getCard(0)
	cardNodeInst.cardVisible = false
	cardNodeInst.playerID = p.UUID
	deckHolder.add_child(cardNodeInst)
	cardNodeInst.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
	cardInst.cardNode = cardNodeInst
	cardNodeInst.position = cardInst.position
	decks[p.UUID] = cardInst
	
	
	cardInst = cardSlot.instance()
	cardInst.currentZone = CardSlot.ZONES.GRAVE
	cardInst.playerID = p.UUID
	$GraveHolder/GraveHolder_A.add_child(cardInst)
	cardInst.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
	cardInst.position = Vector2(0, cardHeight)
	graves[p.UUID] = cardInst
	graveDisplays[p.UUID] = $GraveDisplay_A
	graveCards[p.UUID] = []
	cardNodeInst = cardNode.instance()
	cardNodeInst.card = ListOfCards.getCard(0)
	cardNodeInst.card.cardNode = cardNodeInst
	cardNodeInst.cardVisible = true
	cardNodeInst.visible = false
	cardNodeInst.playerID = p.UUID
	$GraveHolder/GraveHolder_A.add_child(cardNodeInst)
	cardNodeInst.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
	cardInst.cardNode = cardNodeInst
	cardNodeInst.slot = cardInst
	cardNodeInst.position = cardInst.position
	
	
	#	PLAYER 2 SLOTS  	#
	p = players[1]
	
	for i in range(p.creatureNum):
		cardInst = cardSlot.instance()
		cardInst.isOpponent = true
		cardInst.currentZone = CardSlot.ZONES.CREATURE
		cardInst.playerID = p.UUID
		creatures_B_Holder.add_child(cardInst)
		cardInst.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
		creatures[p.UUID].insert(0, cardInst)
		boardSlots.append(cardInst)
	centerNodes(creatures[p.UUID], Vector2(), cardWidth, cardDists)
	
	cardInst = cardSlot.instance()
	cardInst.currentZone = CardSlot.ZONES.DECK
	cardInst.isOpponent = true
	cardInst.playerID = p.UUID
	deckHolder.add_child(cardInst)
	cardInst.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
	cardInst.position = Vector2(0, -cardHeight)
	cardNodeInst = cardNode.instance()
	cardNodeInst.card = ListOfCards.getCard(0)
	cardNodeInst.cardVisible = false
	cardNodeInst.playerID = p.UUID
	deckHolder.add_child(cardNodeInst)
	cardNodeInst.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
	cardInst.cardNode = cardNodeInst
	cardNodeInst.position = cardInst.position
	decks[p.UUID] = cardInst
	
	
	cardInst = cardSlot.instance()
	cardInst.currentZone = CardSlot.ZONES.GRAVE
	cardInst.playerID = p.UUID
	$GraveHolder/GraveHolder_B.add_child(cardInst)
	cardInst.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
	cardInst.position = Vector2(0, -cardHeight)
	graves[p.UUID] = cardInst
	graveDisplays[p.UUID] = $GraveDisplay_B
	graveCards[p.UUID] = []
	cardNodeInst = cardNode.instance()
	cardNodeInst.card = ListOfCards.getCard(0)
	cardNodeInst.card.cardNode = cardNodeInst
	cardNodeInst.cardVisible = true
	cardNodeInst.visible = false
	cardNodeInst.playerID = p.UUID
	$GraveHolder/GraveHolder_B.add_child(cardNodeInst)
	cardNodeInst.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
	cardInst.cardNode = cardNodeInst
	cardNodeInst.slot = cardInst
	cardNodeInst.position = cardInst.position
	
		
func initHands():
	players[0].hand = card_A_Holder
	players[0].initHand()
	players[1].hand = card_B_Holder
	players[1].initHand()
	players[0].hand.deck = decks[players[0].UUID]
	players[1].hand.deck = decks[players[1].UUID]
				
static func centerNodes(nodes : Array, position : Vector2, cardWidth : int, cardDists : int):
	for i in range(nodes.size()):
		nodes[i].position = position + Vector2(-(nodes.size() - 1) / 2.0 * (cardWidth * Settings.cardSlotScale + cardDists) + (cardWidth * Settings.cardSlotScale + cardDists) * i, 0)

var hoveringOn = null

var hoveringWindowSlot = null
var hoveringWindow = null
		
func onSlotEnter(slot : CardSlot):
#	if is_instance_valid(slot.cardNode) and slot.cardNode.getCardVisible() and slot.currentZone == CardSlot.ZONES.CREATURE:
#		slot.cardNode.addIcons()
#		slot.cardNode.iconsShowing = true
	
	if hoveringOn != null:
		onSlotExit(hoveringOn)
	
	hoveringOn = slot
	
	if highlightedSlots.size() > 0:
		for s in highlightedSlots:
			if is_instance_valid(s):
				s.setHighlight(false)
		highlightedSlots.clear()
	
	if cardsHolding.size() > 0:
		var canFuse = true
		
		if (is_instance_valid(slot.cardNode) and not slot.cardNode.getCardVisible()) or slot.currentZone != slot.ZONES.CREATURE:
			canFuse = false
		
		if is_instance_valid(slot.cardNode) and not slot.cardNode.card.canFuseThisTurn:
			canFuse = false
		
		if canFuse:
			var cardsToCheck = []
			if is_instance_valid(slot.cardNode):
				cardsToCheck.append(slot.cardNode.card)
			for s in cardsHolding:
				cardsToCheck.append(s.cardNode.card)
			if not ListOfCards.canFuseCards(cardsToCheck):
				canFuse = false
		
		if canFuse and isMyTurn():
			slot.setHighlight(true)
			highlightedSlots.append(slot)
		
	if slot.playerID != -1:
		if is_instance_valid(selectedCard):
			var opponentHasTaunt = false
			for s in creatures[slot.playerID]:
				if is_instance_valid(s.cardNode) and ListOfCards.hasAbility(s.cardNode.card, AbilityTaunt) and ListOfCards.getAbility(s.cardNode.card, AbilityTaunt).myVars.active:
					opponentHasTaunt = true
			
			if isMyTurn() and not opponentHasTaunt or (is_instance_valid(slot.cardNode) and ListOfCards.hasAbility(slot.cardNode.card, AbilityTaunt) and ListOfCards.getAbility(slot.cardNode.card, AbilityTaunt).myVars.active):
				if slot.playerID != selectedCard.playerID and slot.currentZone == CardSlot.ZONES.CREATURE:
					if ListOfCards.hasAbility(selectedCard.cardNode.card, AbilityPronged):
						for s in slot.getNeighbors():
							s.setHighlight(true)
							highlightedSlots.append(s)
					else:
						slot.setHighlight(true)
						highlightedSlots.append(slot)
		
	if is_instance_valid(slot) and cardsHolding.size() > 0 and slot.currentZone == CardSlot.ZONES.CREATURE:
		for s in cardsHolding:
			s.cardNode.card.onHoverEnter(slot)


func onSlotExit(slot : CardSlot):
	if is_instance_valid(slot):
#		if is_instance_valid(slot.cardNode):
#			slot.cardNode.removeIcons()
#			slot.cardNode.iconsShowing = false
			
		if slot == hoveringOn:
			if highlightedSlots.size() > 0:
				for s in highlightedSlots:
					if is_instance_valid(s):
						s.setHighlight(false)
				highlightedSlots.clear()
			hoveringOn = null

			if is_instance_valid(slot) and cardsHolding.size() > 0 and slot.currentZone == CardSlot.ZONES.CREATURE:
				for s in cardsHolding:
					s.cardNode.card.onHoverExit(slot)
		

func onMouseDown(slot : CardSlot, button_index : int):
	if gameStarted and not gameOver and button_index == 1 and not timers[players[0].UUID].turnOver:
		if selectingSlot:
			slotClicked(slot, button_index)
		else:
			actionQueue.append([slot, button_index])
	elif button_index == 2:
		rightClickQueue.append(slot)
	
func onMouseUp(Slot : CardSlot, button_index : int):
	pass

func slotClicked(slot : CardSlot, button_index : int, fromServer = false) -> bool:
	if button_index == 1 and selectingSlot:
		if (fromServer or players[0].UUID == selectingUUID):
			selectingSource.slotClicked(slot)
		else:
			return false
	else:
		if not is_instance_valid(slot):
			return false
			
		if gameOver:
			return false
			
		if activePlayer == -1:
			return false
		
		if button_index == 2:
			return false
		
		if button_index == 1:
			if slot.currentZone == CardSlot.ZONES.HAND:
				if slot.playerID == players[activePlayer].UUID:
					#ADDING CARDS TO THE FUSION LIST
					if slot.playerID != players[0].UUID and not fromServer:
						return false
					
					if is_instance_valid(selectedCard):
						selectedCard.cardNode.select()
						selectedCard = null
					
					var holdingCost = 0
					for sl in cardsHolding:
						holdingCost += getCardCost(sl.cardNode.card)
					
					
					if is_instance_valid(slot.cardNode):
						if cardsHolding.has(slot):
							SoundEffectManager.playUnselectSound()
							cardsHolding.erase(slot)
							slot.position.y += cardDists
							if hoveringOn != null:
								onSlotExit(slot)
							slot.cardNode.position.y = slot.position.y
						else:
							if cardsPerTurn - cardsPlayed - holdingCost > getCardCost(slot.cardNode.card) - 1:
								if slot.cardNode.card.canBePlayed:
									SoundEffectManager.playSelectSound()
									cardsHolding.append(slot)
									slot.position.y -= cardDists
									slot.cardNode.position.y = slot.position.y
								else:
									if cardsShaking.has(slot) and not fromServer:
										MessageManager.notify("This card cannot be played")
									cardsShaking[slot] = shakeMaxTime
									return false
							else:
								if cardsShaking.has(slot) and not fromServer:
									MessageManager.notify("You may only play " + str(cardsPerTurn) + " per turn")
								cardsShaking[slot] = shakeMaxTime
								return false
						var cost = 0
						for s in cardsHolding:
							cost += getCardCost(s.cardNode.card)
						if activePlayer == 0:
							$CardsLeftIndicator_A.setCardData(cardsPerTurn - cardsPlayed - cost, cost, cardsPlayed)
						else:
							$CardsLeftIndicator_B.setCardData(cardsPerTurn - cardsPlayed - cost, cost, cardsPlayed)
							
			elif slot.currentZone == CardSlot.ZONES.CREATURE:
				if cardsHolding.size() > 0 and cardNodesFusing.size() == 0:
					#PUTTING A CREATURE ONTO THE FIELD
					if not isMyTurn() and not fromServer:
						return false
					
					if is_instance_valid(slot.cardNode) and not slot.cardNode.card.canFuseThisTurn:
						if cardsShaking.has(slot) and not fromServer:
							MessageManager.notify("This creature cannot be fused this turn")
						cardsShaking[slot] = shakeMaxTime
						return false
					##
					var cardsToCheck = []
					if is_instance_valid(slot.cardNode):
						cardsToCheck.append(slot.cardNode.card)
					for s in cardsHolding:
						cardsToCheck.append(s.cardNode.card)
					if not ListOfCards.canFuseCards(cardsToCheck):
						if is_instance_valid(slot.cardNode):
							if cardsShaking.has(slot) and not fromServer:
								MessageManager.notify("A creature can have at most two creature types")
							cardsShaking[slot] = shakeMaxTime
						else:
							var shownMessage = false
							for s in cardsHolding:
								if cardsShaking.has(s) and not shownMessage and not fromServer:
									shownMessage = true
									MessageManager.notify("A creature can have at most two creature types")
								cardsShaking[s] = shakeMaxTime
								
						return false
					##
					
					
					if highlightedSlots.size() > 0:
						for s in highlightedSlots:
							if is_instance_valid(s):
								s.setHighlight(false)
						highlightedSlots.clear()
					
					if is_instance_valid(hoveringOn):
						for s in cardsHolding:
							s.cardNode.card.onHoverExit(slot)
					
					var cardList = []
						
					for c in cardsHolding:
						if hoveringWindowSlot == c:
							if hoveringWindow.close(true):
								hoveringWindowSlot = null
						cardList.append(c.cardNode.card)
						
					var cost = 0
					for s in cardsHolding:
						cost += getCardCost(s.cardNode.card)
					cardsPlayed += cost
					players[activePlayer].addToFlag(Player.CARDS_PLAYED, cardsHolding.size())
					players[activePlayer].addToFlag(Player.MANA_SPENT, cost)
					
					for c in getAllCards():
						c.onCardsPlayed(slot, cardList)
					
					while cardsHolding.size() > 0:
						var c = cardsHolding[0]
						cardsHolding.remove(0)
						var cardNode = c.cardNode
						cardNode.get_parent().remove_child(cardNode)
						card_A_Holder.nodes.erase(cardNode)
						card_B_Holder.nodes.erase(cardNode)
						if c.currentZone == CardSlot.ZONES.HAND:
							card_A_Holder.slots.erase(c)
							card_B_Holder.slots.erase(c)
							c.queue_free()
					
					fuseToSlot(slot, cardList)

					if activePlayer == 0:
						$CardsLeftIndicator_A.setCardData(cardsPerTurn - cardsPlayed, 0, cardsPlayed)
					else:
						$CardsLeftIndicator_B.setCardData(cardsPerTurn - cardsPlayed, 0, cardsPlayed)
						
				else:
					if not isMyTurn() and not fromServer:
						return false
					if slot.playerID == players[activePlayer].UUID:
						#ATTACKING
						if is_instance_valid(slot) and selectedCard == slot:
							selectedCard.cardNode.select()
							selectedCard = null
						else:
							if is_instance_valid(slot.cardNode) and slot.cardNode.card.canAttack():
								if is_instance_valid(selectedCard):
									selectedCard.cardNode.select()
								selectedCard = slot
								selectedCard.cardNode.select()
							else:
								if cardsShaking.has(slot) and not fromServer:
									MessageManager.notify("This creature cannot attack")
								cardsShaking[slot] = shakeMaxTime
								return false
					else:
						if is_instance_valid(selectedCard):
							var opponentHasTaunt = false
							for s in creatures[slot.playerID]:
								if is_instance_valid(s.cardNode) and ListOfCards.hasAbility(s.cardNode.card, AbilityTaunt) and ListOfCards.getAbility(s.cardNode.card, AbilityTaunt).myVars.active:
									opponentHasTaunt = true
							
							if not opponentHasTaunt or (is_instance_valid(slot.cardNode) and ListOfCards.hasAbility(slot.cardNode.card, AbilityTaunt) and ListOfCards.getAbility(slot.cardNode.card, AbilityTaunt).myVars.active):
								var slots = []
								if ListOfCards.hasAbility(selectedCard.cardNode.card, AbilityPronged):
									slots = slot.getNeighbors()
								else:
									slots = [slot]
									
								selectedCard.cardNode.attack(slots)
								if is_instance_valid(selectedCard.cardNode):
									selectedCard.cardNode.select()
								selectedCard = null
								
								if highlightedSlots.size() > 0:
									for s in highlightedSlots:
										if is_instance_valid(s):
											s.setHighlight(false)
									highlightedSlots.clear()
			
							else:
								if cardsShaking.has(slot) and not fromServer:
									MessageManager.notify("A creature with taunt must be attacked first")
								cardsShaking[slot] = shakeMaxTime
								return false
						else:
							return false
	
	return true

func fuseToSlot(slot : CardSlot, cards : Array):
	
	isEntering = not is_instance_valid(slot.cardNode)
	
	if not isEntering:
		if slot == selectedCard:
			selectedCard.cardNode.select()
			selectedCard = null
		cards.insert(0, slot.cardNode.card)
		slot.cardNode.queue_free()
		slot.cardNode = null
	
	if slot == hoveringWindowSlot:
		if is_instance_valid(hoveringWindow):
			if hoveringWindow.close(true):
				hoveringWindowSlot = null
	
	while cards.size() > 0:
		var card = cards[0]
		cards.remove(0)
		
		var cn = cardNode.instance()
		cn.card = card
		card.cardNode = cn
		cn.playerID = slot.playerID
		card.playerID = slot.playerID
		
		cardNodesFusing.append(cn)
		cn.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
		cn.z_index = 1
		$Fusion_Holder.add_child(cn)
		$Fusion_Holder.move_child(cn, 0)
		cn.position = Vector2()
		card_A_Holder.nodes.erase(cn)
		card_B_Holder.nodes.erase(cn)
	
	cardNodesFusing[0].slot = slot
	slot.cardNode = cardNodesFusing[0]
	
	fuseStartPos = cardNodesFusing[0].global_position
	fuseEndSlot = slot
	fuseTimer = 0
	fuseReturnTimer = 0
	
	fuseWaiting = true
	fuseWaitTimer = 0
	
	card_A_Holder.centerCards()
	card_B_Holder.centerCards()
	centerFusion()

func fuseToHand(player : Player, cards : Array):
	while cards.size() > 0:
		var card = cards[0]
		cards.remove(0)
		
		var cn = cardNode.instance()
		cn.card = card
		card.cardNode = cn
		card.playerID = player.UUID
		
		cardNodesFusing.append(cn)
		cn.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
		cn.z_index = 1
		$Fusion_Holder.add_child(cn)
		$Fusion_Holder.move_child(cn, 0)
		cn.position = Vector2()
		card_A_Holder.nodes.erase(cn)
		card_B_Holder.nodes.erase(cn)
	
	fuseStartPos = cardNodesFusing[0].global_position
	isFusingToHand = true
	fusingToHandPlayer = player
	fuseTimer = 0
	fuseReturnTimer = 0
	
	fuseWaiting = true
	fuseWaitTimer = 0
	
	card_A_Holder.centerCards()
	card_B_Holder.centerCards()
	centerFusion()

func centerFusion():
	centerNodes(cardNodesFusing, Vector2((cardWidth * Settings.cardSlotScale + cardDists) * $Fusion_Holder.get_children().size() / 2 - cardWidth / 2 * Settings.cardSlotScale - cardDists / 2, 0), cardWidth, cardDists)

func isMyTurn() -> bool:
	return 0 == activePlayer

func passMyTurn(withBuffer = false):
	return

func isDrawing() -> bool:
	for p in players:
		if p.hand.drawQueue.size() > 0:
			return true
	return false

func getWaiting() -> bool:
	return waitAttacking() or waitDrawing() or waitFusing() or waitMilling() or waitActionQueue() or waitAbilityStack()

func waitAttacking() -> bool:
	for slot in creatures[players[activePlayer].UUID]:
		if is_instance_valid(slot.cardNode) and slot.cardNode.attacking:
			return true
	return false

func waitDrawing() -> bool:
	for p in players:
		if p.hand.drawQueue.size() > 0:
			return true
	return false

func waitFusing() -> bool:
	return cardNodesFusing.size() > 0

func waitMilling() -> bool:
	return millQueue.size() > 0

func waitActionQueue() -> bool:
	return actionQueue.size() > 0

func waitAbilityStack() -> bool:
	return abilityStack.size() > 0


var clickedOff = false
func _input(event):
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.scancode == KEY_F1:
			saveReplay()
		if event.scancode == KEY_F4:
			players[activePlayer].printFlags()
		if event.scancode == KEY_F5:
			serialStore = serialize()
			FileIO.writeToJSON("puzzles", "bak", serialStore)
		if event.scancode == KEY_F6:
			if serialStore != null:
				deserialize(serialStore)
			else:
				var ss = FileIO.readJSON("res://puzzles/bak.json")
				print(ss)
				serialStore = ss
	
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.scancode == KEY_SPACE:
			passMyTurn()
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == 2:
		clickedOff = true

func isOnBoard(card : Card):
	for i in range(players.size()):
		var p = players[(activePlayer + i) % players.size()]
		for s in creatures[p.UUID]:
			if is_instance_valid(s.cardNode) and s.cardNode.card == card:
				return true
	return false

func getCardCost(card) -> int:
	
	var cost = 1
	
	var crs = getAllCards()
	for c in crs:
		cost += c.onAdjustCost(card)
	
	return int(max(min(cost, cardsPerTurnMax), 0))

func getAllCards() -> Array:
	var cards := []
	for i in range(players.size()):
		var p = players[(activePlayer + i) % players.size()]
		
		for c in p.deck.cards:
			cards.append(c)
		
		for s in p.hand.slots:
			if is_instance_valid(s.cardNode):
				cards.append(s.cardNode.card)
		for s in creatures[p.UUID]:
			if is_instance_valid(s.cardNode):
				cards.append(s.cardNode.card)
		for cn in cardNodesFusing:
			cards.append(cn.card)
				
		for c in graveCards[p.UUID]:
			cards.append(c)
		
		cards.append(delayedAbilityCards[p.UUID])
		
	cards.invert()
	return cards

func getAllPlayers() -> Array:
	var pl := []
	for i in range(players.size()):
		var p = players[(activePlayer + i) % players.size()]
		pl.append(p)
	return pl

func getAllCreatures() -> Array:
	var cards := []
	for p in getAllPlayers():
		for s in creatures[p.UUID]:
			if is_instance_valid(s.cardNode):
				cards.append(s.cardNode.card)
	cards.invert()
	return cards

func nextTurn():
	var waiting = getWaiting()
	while waiting:
		waiting = getWaiting()
		yield(get_tree().create_timer(0.1), "timeout")
	
	if gameOver:
		return
	dataLog.append("NEXT_TURN")
	
	var lastHover = hoveringOn
	if hoveringOn != null:
		onSlotExit(hoveringOn)
	
	while cardsHolding.size() > 0:
		cardsHolding[0].position.y += cardDists
		cardsHolding[0].cardNode.position.y = cardsHolding[0].position.y
		cardsHolding.remove(0)
	if is_instance_valid(selectedCard):
		selectedCard.cardNode.select()
		selectedCard = null
	
	if hoveringOn != null:
		onSlotEnter(hoveringOn)
	
	
	checkState()
	
	######################	ON END OF TURN EFFECTS
	for c in getAllCards():
		c.onEndOfTurn()
	######################
	
	checkState()
	
	while abilityStack.size() > 0:
		yield(get_tree().create_timer(0.1), "timeout")
	
	if activePlayer == 0 or Settings.gameMode == Settings.GAME_MODE.PRACTICE:
		endTimer(activePlayer)
		resetTimer(activePlayer)
	
	
	cardsPlayed = 0
	activePlayer = (activePlayer + 1) % players.size()
	setTurnText()
	
	cardsPerTurn = cardsPerTurnMax
	if activePlayer == 0:
		$CardsLeftIndicator_A.setCardData(cardsPerTurn - cardsPlayed, 0, cardsPlayed)
	else:
		$CardsLeftIndicator_B.setCardData(cardsPerTurn - cardsPlayed, 0, cardsPlayed)
	
	
	######################	ON START OF TURN EFFECTS
	for p in players:
		p.onStartOfTurn()
	for c in getAllCards():
		c.onStartOfTurn()
	
	######################
	
	while abilityStack.size() > 0:
		yield(get_tree().create_timer(0.1), "timeout")
				
	
	players[activePlayer].hand.drawCard()
	
	while abilityStack.size() > 0:
		yield(get_tree().create_timer(0.1), "timeout")
	
	if activePlayer == 0 or Settings.gameMode == Settings.GAME_MODE.PRACTICE:
		startTimer(activePlayer)
		resetTimer(activePlayer)

func addCardsPerTurn(inc : int):
	cardsPerTurn += inc
	if activePlayer == 0:
		$CardsLeftIndicator_A.setCardData(cardsPerTurn - cardsPlayed, 0, cardsPlayed)
	else:
		$CardsLeftIndicator_B.setCardData(cardsPerTurn - cardsPlayed, 0, cardsPlayed)

func addCardsPlayed(inc : int):
	cardsPlayed += inc
	if activePlayer == 0:
		$CardsLeftIndicator_A.setCardData(cardsPerTurn - cardsPlayed, 0, cardsPlayed)
	else:
		$CardsLeftIndicator_B.setCardData(cardsPerTurn - cardsPlayed, 0, cardsPlayed)

var serialStore = null

func serialize() -> Dictionary:
	var rtn = {}
	
	var creatureData = []
	var playerData = []
	var deckData = []
	var graveData = []
	var handData = []
	var delayedData = []
	
	var turnData = []
	
	for p in getAllPlayers():
		
		#	GETTING DATA OF CREATURES ON THE BOARD	#
		var cd = []
		for s in creatures[p.UUID]:
			if is_instance_valid(s.cardNode):
				cd.append(s.cardNode.card.serialize())
			else:
				cd.append({})
		creatureData.append(cd)
		
		#	GETTING DATA OF PLAYERS 	#
		var pd = [p.life, p.armour, p.drawDamage]
		playerData.append(pd)
		
		#	GETTING DECK DATA	#
		deckData.append(p.deck.serialize())
		
		#	GETTING GRAVE DATA	#
		var gd = []
		for c in graveCards[p.UUID]:
			gd.append(c.serialize())
		graveData.append(gd)
		
		#	GETTING HAND DATA	#
		var hd = []
		for cn in p.hand.nodes:
			hd.append([cn.card.serialize(), cn.getCardVisible() if p.hand.isOpponent else cn.slot.get_node("EyeSprite").visible])
		handData.append(hd)
		
		#	GETTING DELAYED ABILITIES	#
		var ad = delayedAbilityCards[p.UUID].serialize()
		delayedData.append(ad)
		
	#	GETTING TURN DATA	#
	turnData = [activePlayer, cardsPlayed, cardsPerTurn]
	
	#DELAYED ABILITIES!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	
		
	rtn["creatures"] = creatureData
	rtn["players"] = playerData
	rtn["decks"] = deckData
	rtn["graves"] = graveData
	rtn["hands"] = handData
	rtn["delays"] = delayedData
	rtn["turnData"] = turnData
	
	return rtn

func deserialize(data : Dictionary):
	var creatureData = data["creatures"]
	var playerData = data["players"]
	var deckData = data["decks"]
	var graveData = data["graves"]
	var handData = data["hands"]
	var delayedData = data["delays"]
	var turnData = data["turnData"]
	
	for i in range(players.size()):
		var p = players[i]
		
		var cd = creatureData[i]
		var pd = playerData[i]
		var dd = deckData[i]
		var gd = graveData[i]
		var hd = handData[i]
		
		#	CREATURE DATA	#
		for j in range(cd.size()):
			var slot = creatures[p.UUID][j]
			if cd[j].empty():
				if not is_instance_valid(slot.cardNode):
					continue
				else:
					slot.cardNode.queue_free()
					slot.cardNode.slot = null
					slot.cardNode = null
			else:
				if is_instance_valid(slot.cardNode) and cd[j] == slot.cardNode.card.serialize():
					continue
				else:
					var card = ListOfCards.deserialize(cd[j])
					card.playerID = slot.playerID
					card.ownerID = slot.playerID
					if is_instance_valid(slot.cardNode):
						slot.cardNode.card.cardNode = null
						slot.cardNode.card = card
						card.cardNode = slot.cardNode
						card.cardNode.setCardVisible(card.cardNode.getCardVisible())
					else:
						var cn = cardNode.instance()
						cn.scale = Vector2(Settings.cardSlotScale, Settings.cardSlotScale)
						cn.card = card
						cn.card.cardNode = cn
						slot.cardNode = cn
						cn.slot = slot
						add_child(cn)
						cn.global_position = slot.global_position
						cn.playerID = slot.playerID
						cn.setCardVisible(cn.getCardVisible())
		
		#	PLAYER DATA 	#
		p.life			 = pd[0]
		p.lifeNode.get_node("Label").text = "Life: " + str(p.life)
		p.armour		 = pd[1]
		p.drawDamage	 = pd[2]
		for k in p.flags:
			p.flags[k] = Player.defaultFlag.duplicate(true)
		
		#	DECK DATA	#
		p.deck.deserialize(dd)
		
		
		#	GRAVE DATA	#
		for j in range(graveCards[p.UUID].size()):
			removeCardFromGrave(p.UUID, 0)
		for j in range(gd.size()):
			var card = ListOfCards.deserialize(gd[j])
			addCardToGrave(p.UUID, card)
		
		#	HAND DATA	#
		p.hand.clear()
		for j in range(hd.size()):
			var card = ListOfCards.deserialize(hd[j][0])
			p.hand.addCardToHand([card, false, hd[j][1]], false)
		
		#	DELAYED DATA	#
		delayedAbilityCards[p.UUID] = ListOfCards.deserialize(delayedData[i])
		
	#	Turn Data	#
	activePlayer = 	turnData[0]
	cardsPlayed = 	turnData[1]
	cardsPerTurn = 	turnData[2]
	
	if activePlayer == 0:
		$CardsLeftIndicator_A.setCardData(cardsPerTurn - cardsPlayed, 0, cardsPlayed)
		$CardsLeftIndicator_B.setCardData(cardsPerTurn, 0, 0)
	else:
		$CardsLeftIndicator_A.setCardData(cardsPerTurn, 0, 0)
		$CardsLeftIndicator_B.setCardData(cardsPerTurn - cardsPlayed, 0, cardsPlayed)
	

func checkState():
	serialize()
	
	var boardState = []
	var slots = []
	
	if is_instance_valid(hoveringWindow) and is_instance_valid(hoveringWindowSlot) and is_instance_valid(hoveringWindowSlot.cardNode):
		if hoveringWindowSlot.currentZone != CardSlot.ZONES.DECK:
			hoveringWindow.setText(hoveringWindowSlot.cardNode.card.getHoverData())
	
	for p in getAllPlayers():
		for s in creatures[p.UUID]:
			if is_instance_valid(s.cardNode):
				boardState.append(s.cardNode.card.serialize())
			else:
				boardState.append({})
	
	var creaturesDying = []
	for p in getAllPlayers():
		for s in creatures[p.UUID]:
			if is_instance_valid(s.cardNode):
				if s.cardNode.card.toughness <= 0 or s.cardNode.card.isDying:
					creaturesDying.append(s.cardNode)
				
	for cardNode in creaturesDying:
		SoundEffectManager.playDeathSound()
		cardNode.card.onLeave()
		cardNode.card.onDeath()
		
		for c in getAllCards():
			if c != cardNode.card:
				c.onOtherLeave(cardNode.slot)
				c.onOtherDeath(cardNode.slot)
		
		if cardNode.card.toughness <= 0 or cardNode.card.isDying:
			if hoveringWindowSlot == cardNode.slot:
				hoveringWindow.close(true)
				hoveringWindowSlot = null
			addCardToGrave(cardNode.card.playerID, cardNode.card)
			cardNode.slot.cardNode = null
			cardNode.queue_free()

	var boardStateNew = []
	for p in getAllPlayers():
		for s in creatures[p.UUID]:
			if is_instance_valid(s.cardNode):
				boardStateNew.append(s.cardNode.card.serialize())
			else:
				boardStateNew.append({})
	
	#[card(moving), ability(source), slot(moving to)]
	if cardsMovingCard.size() > 0:
		for c in getAllCards():
			if isOnBoard(c) and not c in cardsMovingCard:
				cardsMovingCard.append(c)
				cardsMovingAbility.append(null)
				cardsMovingSlot.append(c.cardNode.slot)
		
		var resolved = false
		while not resolved:
			var errorSlots : Array = []
			
			for i in range(0, cardsMovingCard.size(), 1):
				for j in range(i+1, cardsMovingCard.size(), 1):
					if cardsMovingSlot[i] == cardsMovingSlot[j]:
						errorSlots.append([i, j])
#						print("ERROR DECTED IN MOVING")
			
			resolved = errorSlots.size() == 0
			
			for e in errorSlots:
				cardsMovingAbility[e[0]] = null
				cardsMovingAbility[e[1]] = null
				cardsMovingSlot[e[0]] = cardsMovingCard[e[0]].cardNode.slot
				cardsMovingSlot[e[1]] = cardsMovingCard[e[1]].cardNode.slot
			errorSlots.clear()
		
		for i in range(cardsMovingCard.size()):
			if cardsMovingCard[i].cardNode.slot != cardsMovingSlot[i]:
				if is_instance_valid(cardsMovingCard[i].cardNode.slot):
					cardsMovingCard[i].cardNode.slot.cardNode = null
					cardsMovingCard[i].cardNode.slot = null
				
				if is_instance_valid(cardsMovingSlot[i].cardNode):
					cardsMovingSlot[i].cardNode.slot = null
					cardsMovingSlot[i].cardNode = null
				
				cardsMovingCard[i].cardNode.slot = cardsMovingSlot[i]
				cardsMovingSlot[i].cardNode = cardsMovingCard[i].cardNode
				cardsMovingSlot[i].cardNode.global_position = cardsMovingSlot[i].global_position
				
				cardsMovingCard[i].playerID = cardsMovingSlot[i].playerID
				cardsMovingCard[i].cardNode.playerID = cardsMovingSlot[i].playerID
	
		cardsMovingCard.clear()
		cardsMovingAbility.clear()
		cardsMovingSlot.clear()
			
	
	for i in range(boardState.size()):
		if not Card.areIdentical(boardState[i], boardStateNew[i]):
			#yield(get_tree().create_timer(0.1), "timeout")
			checkState()

func getSlot(source, selectingUUID : int):
	selectingSlot = true
	selectingSource = source
	self.selectingUUID = selectingUUID
	stackTimer = 0
	
	endTimer(timerPlayer)
	
	if players[0].UUID == selectingUUID:
		startTimer(0)
	elif players[1].UUID == selectingUUID and Settings.gameMode == Settings.GAME_MODE.PRACTICE:
		startTimer(1)

func endGetSlot():
	selectingSlot = false
	selectingSource = null
	abilityStack.remove(0)
	if abilityStack.size() > 0:
		stackTimer = stackMaxTime
	currentAbility = null
	
	if players[0].UUID == selectingUUID:
		endTimer(0)
	elif players[1].UUID == selectingUUID and Settings.gameMode == Settings.GAME_MODE.PRACTICE:
		endTimer(1)
		
	startTimer(activePlayer)
	
	checkState()

func getType(source, selectingUUID : int):
	if selectingUUID == players[0].UUID:
		typeDisplay.show()
	
	selectingType = true
	selectingSource = source
	self.selectingUUID = selectingUUID
	stackTimer = 0
	
	endTimer(timerPlayer)
	
	if players[0].UUID == selectingUUID:
		startTimer(0)
	elif players[1].UUID == selectingUUID and Settings.gameMode == Settings.GAME_MODE.PRACTICE:
		startTimer(1)

func endGetType():
	selectingType = false
	selectingSource = null
	abilityStack.remove(0)
	if abilityStack.size() > 0:
		stackTimer = stackMaxTime
	currentAbility = null
	
	if players[0].UUID == selectingUUID:
		endTimer(0)
	elif players[1].UUID == selectingUUID and Settings.gameMode == Settings.GAME_MODE.PRACTICE:
		endTimer(1)
		
	startTimer(activePlayer)
	
	checkState()

func onTypeButtonPressed(button, key):
	typeDisplay.hide()
	selectingSource.onTypeSelected(button, key)

func onLoss(player : Player):
	if not gameOver and not deadPlayers.has(player):
		deadPlayers.append(player)

func startTimer(playerNum):
	if not gameOver:
		timers[players[playerNum].UUID].startTurnTimer()
		
		if playerNum == 0:
			Server.sendStartTimer(Server.opponentID)
		
		timerPlayer = playerNum

func endTimer(playerNum):
	timers[players[playerNum].UUID].stopTurnTimer()
	
	if playerNum == 0:
		Server.sendEndTimer(Server.opponentID, timers[players[0].UUID].gameTimer)
	
	timerPlayer = -1

func resetTimer(playerNum):
	if not gameOver:
		timers[players[playerNum].UUID].resetTurnTimer()
		
		if playerNum == 0:
			Server.sendResetTimer(Server.opponentID)

func onTurnTimerEnd():
	passMyTurn(true)

func onGameTimerEnd():
	onLoss(players[0])
	Server.onConcede(Server.opponentID)

func receiveMessage(message : String):
	print(message)

func setOwnUsername():
	print("Settings own username")
	$UsernameLabel.text = SilentWolf.Auth.logged_in_player
	dataLog.append("SET_OWN_USERNAME " + $UsernameLabel.text)
	
	if Server.online:
		setOpponentUsername(Server.playerNames[Server.opponentID])
	else:
		setOpponentUsername(practiceNames[randi() % practiceNames.size()])

const practiceNames : Array = ["Sparky", "Durandal", "Durian", "Gumbercules", "Mecha_Jesus", "Bones", "Luna", "Olive", "Rocky", "Stitch", "Jet", \
	"Moxie", "Robert Baratheon, First of his Name", "Sinbad", "Sniffy"]

func setOpponentUsername(username : String):
	print("Settings opponent username")
	$UsernameLabel2.text = username
	dataLog.append("SET_OPPONENT_USERNAME " + username)

func editOwnName(username):
	setOwnUsername()

func editPlayerName(player_id : int, username : String):
	if player_id == Server.opponentID:
		setOpponentUsername(username)

var dataLog := []

func saveReplay():
	FileIO.dumpDataLog(dataLog)
