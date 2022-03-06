extends Node2D

class_name CardNode

var abilityIcon = preload("res://Scripts/UI/AbilityIcon.tscn")

var slot
var card
var playerID = -1

var attacking = false
var dealtDamage = false
var attackingPositions = []
var attackReturnPos = null
var attackingSlots = null
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
var originalScale = 1

var cardVisible = true setget setCardVisible, getCardVisible

func _ready():
	setCardVisible(cardVisible)
			
func setCardVisible(isVis : bool):
	if isVis:
		if card != null:
			$Label.visible = true
			$CardType.visible = true
			$CardType.texture = ListOfCards.creatureTypeImageList[card.creatureType[0]]
			
			if card.creatureType.size() > 1:
				$CardType2.visible = true
				$CardType2.texture = ListOfCards.creatureTypeImageList[card.creatureType[1]]
			else:
				$CardType2.visible = false
				
			$CardPortrait.texture = card.texture
			
		else:
			$CardPortrait.texture = ListOfCards.noneCardTex
			$Label.visible = false
	else:
		$CardPortrait.texture = ListOfCards.unknownCardTex
		$CardType.visible = false
		$Label.visible = false
	cardVisible = isVis
		
func getCardVisible() -> bool:
	return cardVisible

func _physics_process(delta):
	if card != null:
		$Label.text = str(card.power) + " / " + str(card.toughness)
		
	if is_instance_valid(card) and is_instance_valid(slot) and slot.currentZone == CardSlot.ZONES.CREATURE:
		$CardBackground.texture = (ListOfCards.cardBackground if (card.hasAttacked or not card.canAttackThisTurn) else ListOfCards.cardBackgroundActive)
		
	if flipping:
		flipTimer += delta
		scale.x = abs(cos(flipTimer / flipMaxTime * PI)) * originalScale
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
			global_position = lerp(attackReturnPos, attackingPositions[0], attackTimer / attackMaxTime)
		elif attackWaitTimer < attackWaitMaxTime:
			attackWaitTimer += delta
		elif attackReturnTimer < attackReturnMaxTime:
			if not dealtDamage:
				fight(attackingSlots[0], slot.board)
				dealtDamage = true
			attackReturnTimer += delta
			global_position = lerp(attackingPositions[0], attackReturnPos, attackReturnTimer / attackReturnMaxTime)
			rotation = lerp(attackRotation, 0, attackReturnTimer / attackReturnMaxTime)
		else:
			global_position = attackReturnPos
			rotation = 0
			
			attackingPositions.remove(0)
			attackingSlots.remove(0)
			attackStartupTimer = 0
			attackWaitTimer = 0
			attackTimer = 0
			attackReturnTimer = 0
			dealtDamage = false
			if attackingSlots.size() == 0:
				attacking = false
				z_index -= 1
				attackReturnPos = null
			else:
				attackRotation = attackReturnPos.angle_to_point(attackingPositions[0])
				if attackRotation > PI:
					attackRotation -= PI
				elif attackRotation < 0:
					attackRotation += PI
				attackRotation -= PI / 2
			

func takeDamage(dmg : int, board):
	card.toughness -= dmg

func attack(board, slots : Array):
	if Settings.playAnimations:
		z_index += 1
		attacking = true
		dealtDamage = false
		attackWaitTimer = 0
		attackingSlots = slots
		attackingPositions.clear()
		for s in slots:
			attackingPositions.append(s.global_position + (global_position - s.global_position).normalized() * ListOfCards.cardBackground.get_width() * Settings.cardSlotScale)
		attackReturnPos = global_position
		attackRotation = attackReturnPos.angle_to_point(attackingPositions[0])
		if attackRotation > PI:
			attackRotation -= PI
		elif attackRotation < 0:
			attackRotation += PI
		attackRotation -= PI / 2
		
	else:
		for s in slots:
			fight(s, slot.board)

func flip():
	flipping = true
	originalScale = scale.x
	
func fight(slot, board, damageSelf = true):
	var venomA = ListOfCards.getAbility(card, AbilityVenemous).count * 2 if ListOfCards.hasAbility(card, AbilityVenemous) and is_instance_valid(slot.cardNode) else 0
	var venomB = 0
	if venomA > 0:
		card.power += venomA
	if is_instance_valid(slot.cardNode):
		venomB = ListOfCards.getAbility(slot.cardNode.card, AbilityVenemous).count * 2 if ListOfCards.hasAbility(slot.cardNode.card, AbilityVenemous) and is_instance_valid(slot.cardNode) else 0
		if venomB > 0:
			slot.cardNode.card.power += venomB
	
	
	card.onAttack(slot, board)
	if is_instance_valid(slot.cardNode):
		slot.cardNode.card.onBeingAttacked(self.slot, board)
	if is_instance_valid(slot.cardNode):
		if damageSelf:
			takeDamage(max(slot.cardNode.card.power, 0), board)
		slot.cardNode.takeDamage(max(card.power, 0), board)
		
		if ListOfCards.hasAbility(card, AbilityRampage) and slot.cardNode.card.toughness < 0:
			for p in slot.board.players:
				if p.UUID == slot.playerID:
					var damage = -slot.cardNode.card.toughness
					p.takeDamage(damage, self)
		
	else:
		for p in slot.board.players:
			if p.UUID == slot.playerID:
				var damage = max(card.power, 0)
				p.takeDamage(damage, self)
	
	
	if venomA > 0:
		card.power -= venomA
	if venomB > 0:
		slot.cardNode.card.power -= venomB
				
	board.checkState()
				
func _exit_tree():
	if is_instance_valid(slot) and is_instance_valid(slot.board):
		slot.board.onSlotExit(slot)

func addIcons():
	for abl in card.abilities:
		var ico = abilityIcon.instance()
		ico.texture = ico.texture.duplicate()
		ico.texture.region.position = abl.iconPos
		$VBoxContainer.add_child(ico)

func removeIcons():
	for c in $VBoxContainer.get_children():
		$VBoxContainer.remove_child(c)
		c.queue_free()
