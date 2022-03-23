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

var iconsShowing = false

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

var waitingForStackToClear = false

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
			
	if attacking and NodeLoc.getBoard().abilityStack.size() == 0 and NodeLoc.getBoard().fuseQueue.size() == 0:
		if attackStartupTimer < attackStartupMaxTime:
			attackStartupTimer += delta
			rotation = lerp(0, attackRotation, attackStartupTimer / attackStartupMaxTime)
		elif attackTimer < attackMaxTime:
			attackTimer += delta
			global_position = lerp(attackReturnPos, attackingPositions[0], attackTimer / attackMaxTime)
		elif attackWaitTimer < attackWaitMaxTime:
			attackWaitTimer += delta
		elif attackReturnTimer < attackReturnMaxTime:
			if not waitingForStackToClear:
				if not dealtDamage:
					waitingForStackToClear = true
					fight(attackingSlots[0])
					waitingForStackToClear = false
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
			

func takeDamage(dmg : int):
	card.toughness -= dmg

func attack(slots : Array):
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
			fight(s)

func flip():
	flipping = true
	originalScale = scale.x
	
func fight(slot, damageSelf = true):
	var venomA = ListOfCards.getAbility(card, AbilityVenomous).count if ListOfCards.hasAbility(card, AbilityVenomous) and is_instance_valid(slot.cardNode) else 0
	var venomB = 0
	if venomA > 0:
		card.power += venomA
	if is_instance_valid(slot.cardNode):
		venomB = ListOfCards.getAbility(slot.cardNode.card, AbilityVenomous).count if ListOfCards.hasAbility(slot.cardNode.card, AbilityVenomous) and is_instance_valid(slot.cardNode) else 0
		if venomB > 0:
			slot.cardNode.card.power += venomB
	
	card.onAttack(slot)
	if is_instance_valid(slot.cardNode):
		slot.cardNode.card.onBeingAttacked(self.slot)
		
		for c in NodeLoc.getBoard().getAllCards():
			var isAttacker = c == card
			var isBlocker = is_instance_valid(slot.cardNode) and c == slot.cardNode.card
			if not isAttacker:
				c.onOtherAttack(self.slot, slot)
			if not isBlocker:
				c.onOtherBeingAttacked(self.slot, slot)
	
	while NodeLoc.getBoard().abilityStack.size() > 0 or NodeLoc.getBoard().fuseQueue.size() > 0:
		yield(get_tree().create_timer(0.1), "timeout")
	
	if is_instance_valid(slot.cardNode):
		if damageSelf:
			takeDamage(max(slot.cardNode.card.power, 0))
		slot.cardNode.takeDamage(max(card.power, 0))
		
		if ListOfCards.hasAbility(card, AbilityRampage) and slot.cardNode.card.toughness < 0:
			for p in NodeLoc.getBoard().players:
				if p.UUID == slot.playerID:
					var damage = -slot.cardNode.card.toughness
					p.takeDamage(damage, self)
		
	else:
		for p in NodeLoc.getBoard().players:
			if p.UUID == slot.playerID:
				var damage = max(card.power, 0)
				p.takeDamage(damage, self)
	
	
	if venomA > 0:
		card.power -= venomA
	if venomB > 0:
		slot.cardNode.card.power -= venomB
				
	NodeLoc.getBoard().checkState()
				
func _exit_tree():
	if is_instance_valid(slot) and get_parent().has_method("onSlotExit"):
		NodeLoc.getBoard().onSlotExit(slot)

func addIcons():
	for abl in card.abilities:
		var ico = abilityIcon.instance()
		ico.texture = ico.texture.duplicate()
		ico.texture.region.position = abl.iconPos
		$IconZIndex/VBoxContainer.add_child(ico)

func removeIcons():
	for c in $IconZIndex/VBoxContainer.get_children():
		$IconZIndex/VBoxContainer.remove_child(c)
		c.queue_free()
