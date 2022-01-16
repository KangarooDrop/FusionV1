extends Node2D

class_name CardNode

var slot
var card
var playerID = -1

var attacking = false
var dealtDamage = false
var attackPos = null
var attackReturnPos = null
var attackingSlot = null
var attackRotation = 0
var attackStartupTimer = 0
var attackStartupMaxTime = 0.1
var attackTimer = 0
var attackMaxTime = 0.1
var attackWaitTimer = 0
var attackWaitMaxTime = 0.3
var attackReturnTimer = 0
var attackReturnMaxTime = 0.2

var flipping = false
var hasFlipped = false
var flipTimer = 0
var flipMaxTime = 0.5

var cardVisible = true setget setCardVisible, getCardVisible

func _ready():
	setCardVisible(cardVisible)
			
			
func setCardVisible(isVis : bool):
	if isVis:
		if card != null:
			if card.cardType == Card.CARD_TYPE.Creature:
				$Label.visible = true
				$CardType.visible = true
				$CardType.texture = ListOfCards.creatureTypeImageList[card.creatureType]
			$CardPortrait.texture = card.texture
		else:
			$CardPortrait.texture = ListOfCards.noneCardTex
			$Label.visible = false
	else:
		$CardPortrait.texture = ListOfCards.unknownCardTex
		$CardType.visible = false
	cardVisible = isVis
		
func getCardVisible() -> bool:
	return cardVisible

func _physics_process(delta):
	if card != null and card.cardType == Card.CARD_TYPE.Creature:
		$Label.text = str(card.power) + "/" + str(card.toughness)
		
	if is_instance_valid(card) and card.cardType == Card.CARD_TYPE.Creature and is_instance_valid(slot) and slot.currentZone == CardSlot.ZONES.CREATURE:
		$CardBackground.texture = (ListOfCards.cardBackground if card.hasAttacked else ListOfCards.cardBackgroundActive)
		
	if flipping:
		flipTimer += delta
		scale.x = abs(cos(flipTimer / flipMaxTime * PI))
		if not hasFlipped and flipTimer >= flipMaxTime / 2:
			hasFlipped = true
			setCardVisible(!getCardVisible())
		if flipTimer >= flipMaxTime:
			flipMaxTime = 0
			hasFlipped = false
			flipping = false
			
	if attacking:
		if attackStartupTimer < attackStartupMaxTime:
			attackStartupTimer += delta
			rotation = lerp(0, attackRotation, attackStartupTimer / attackStartupMaxTime)
		elif attackTimer < attackMaxTime:
			attackTimer += delta
			global_position = lerp(attackReturnPos, attackPos, attackTimer / attackMaxTime)
		elif attackWaitTimer < attackWaitMaxTime:
			attackWaitTimer += delta
		elif attackReturnTimer < attackReturnMaxTime:
			if not dealtDamage:
				dealDamageTo(attackingSlot, slot.board)
				dealtDamage = true
			attackReturnTimer += delta
			global_position = lerp(attackPos, attackReturnPos, attackReturnTimer / attackReturnMaxTime)
			rotation = lerp(attackRotation, 0, attackReturnTimer / attackReturnMaxTime)
		else:
			global_position = attackReturnPos
			rotation = 0
			
			attacking = false
			attackPos = null
			attackReturnPos = null
			attackStartupTimer = 0
			attackTimer = 0
			attackReturnTimer = 0
			

func takeDamage(dmg : int, board):
	card.toughness -= dmg

func attack(pos, slot):
	if Settings.playAnimations:
		attacking = true
		dealtDamage = false
		attackWaitTimer = 0
		attackPos = pos
		attackingSlot = slot
		attackReturnPos = global_position
		attackRotation = attackReturnPos.angle_to_point(attackPos)
		if attackRotation > PI:
			attackRotation -= PI
		elif attackRotation < 0:
			attackRotation += PI
		attackRotation -= PI / 2
	else:
		dealDamageTo(slot, slot.board)

func flip():
	flipping = true
	
func dealDamageTo(slot, board):
	if is_instance_valid(slot.cardNode):
		takeDamage(slot.cardNode.card.power, board)
		slot.cardNode.takeDamage(card.power, board)
		
		if card.toughness <= 0:
			card.onDeath(board)
			self.slot.cardNode = null
			queue_free()
		if slot.cardNode.card.toughness <= 0:
			slot.cardNode.card.onDeath(board)
			slot.cardNode.queue_free()
			slot.cardNode = null
	else:
		for p in slot.board.players:
			if p.UUID == slot.playerID:
				p.takeDamage(card.power, self)
