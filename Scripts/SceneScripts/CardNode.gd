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
var attackingSlots := []
var attackingIndex = -1
var attackRotation = 0
var attackStartupTimer = 0
var attackStartupMaxTime = 0.1
var attackTimer = 0
var attackMaxTime = 0.1
var attackWaitTimer = 0
var attackWaitMaxTime = 0.1
var attackReturnTimer = 0
var attackReturnMaxTime = 0.2

var flipping = false
var hasFlipped = false
var flipTimer = 0
var flipMaxTime = 0.5
var originalScale = 1

var fightingWait = false

var cardVisible = true setget setCardVisible, getCardVisible

var iconsShowing = false

var isSelected = false
var selectedTimer = 0

func _ready():
	setCardVisible(cardVisible)
			
func setCardVisible(isVis : bool):
	if isVis:
		if card != null:
			$Label.visible = true
			if card.creatureType.size() > 0:
				$CardType.visible = true
				$CardType.texture = ListOfCards.creatureTypeImageList[card.creatureType[0]]
			else:
				$CardType.visible = false
			
			if card.creatureType.size() > 1:
				$CardType2.visible = true
				$CardType2.texture = ListOfCards.creatureTypeImageList[card.creatureType[1]]
			else:
				$CardType2.visible = false
				
			$CardPortrait.texture = card.texture
			$CardRarity.visible = true
			$CardRarity.region_rect = Rect2(Vector2(14 * (card.rarity - 1), 0), Vector2(14, 14))
			
		else:
			$CardPortrait.texture = ListOfCards.noneCardTex
			$Label.visible = false
			$CardRarity.visible = false
	else:
		$CardPortrait.texture = ListOfCards.unknownCardTex
		$CardType.visible = false
		$CardType2.visible = false
		$Label.visible = false
		$CardRarity.visible = false
	cardVisible = isVis
		
func getCardVisible() -> bool:
	return cardVisible

var waitingForStackToClear = false

func select():
	isSelected = not isSelected
	selectedTimer = 0
	rotation = 0

func _physics_process(delta):
	if isSelected:
		selectedTimer += delta
		rotation = sin(selectedTimer * 1.5) * PI / 32
	
	if card != null:
		$Label.text = str(card.power) + " / " + str(card.toughness)
		
	if is_instance_valid(card) and is_instance_valid(slot) and slot.currentZone == CardSlot.ZONES.CREATURE:
		$CardBackground.texture = (ListOfCards.cardBackground if (not card.canAttack()) else ListOfCards.cardBackgroundActive)
		
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
			
	if attacking and NodeLoc.getBoard().getCanFight():
		if not fightingWait:
			if attackStartupTimer < attackStartupMaxTime:
				attackStartupTimer += delta
				rotation = lerp(0, attackRotation, attackStartupTimer / attackStartupMaxTime)
			elif attackTimer < attackMaxTime:
				attackTimer += delta
				global_position = lerp(attackReturnPos, attackingPositions[attackingIndex], attackTimer / attackMaxTime)
			elif attackWaitTimer < attackWaitMaxTime:
				attackWaitTimer += delta
			elif attackReturnTimer < attackReturnMaxTime:
				if not waitingForStackToClear:
					if not dealtDamage:
						waitingForStackToClear = true
						fight(attackingSlots[attackingIndex])
						waitingForStackToClear = false
						dealtDamage = true
					if not fightingWait:
						attackReturnTimer += delta
						global_position = lerp(attackingPositions[attackingIndex], attackReturnPos, attackReturnTimer / attackReturnMaxTime)
						rotation = lerp(attackRotation, 0, attackReturnTimer / attackReturnMaxTime)
			else:
				global_position = attackReturnPos
				rotation = 0
				
				attackingIndex += 1
				attackStartupTimer = 0
				attackWaitTimer = 0
				attackTimer = 0
				attackReturnTimer = 0
				dealtDamage = false
				if attackingIndex >= attackingSlots.size():
			
					for s in attackingSlots:
						if is_instance_valid(s.cardNode):
							s.cardNode.card.onAfterCombat(slot, attackingSlots.duplicate())
					card.onAfterCombat(slot, attackingSlots.duplicate())
					
					attackingSlots.clear()
					attackReturnPos = null
					attacking = false
					z_index -= 1
				else:
					attackRotation = attackReturnPos.angle_to_point(attackingPositions[attackingIndex])
					if attackRotation > PI:
						attackRotation -= PI
					elif attackRotation < 0:
						attackRotation += PI
					attackRotation -= PI / 2

func attack(slots : Array):
	card.hasAttacked = true
	
	for s in slots:
		if is_instance_valid(s.cardNode):
			s.cardNode.card.onBeforeCombat(slot, slots)
	card.onBeforeCombat(slot, slots)
	
	if Settings.playAnimations:
		attackingIndex = 0
		z_index += 1
		attacking = true
		dealtDamage = false
		attackWaitTimer = 0
		attackingSlots = slots
		attackingPositions.clear()
		for s in slots:
			attackingPositions.append(s.global_position + (global_position - s.global_position).normalized() * ListOfCards.cardBackground.get_width() * Settings.cardSlotScale)
		attackReturnPos = global_position
		attackRotation = attackReturnPos.angle_to_point(attackingPositions[attackingIndex])
		if attackRotation > PI:
			attackRotation -= PI
		elif attackRotation < 0:
			attackRotation += PI
		attackRotation -= PI / 2
		
	else:
		for s in slots:
			fight(s)
			
		for s in slots:
			if is_instance_valid(s.cardNode):
				s.cardNode.card.onAfterCombat(slot, slots)
		card.onAfterCombat(slot, slots)

func flip():
	flipping = true
	originalScale = scale.x
	
func fight(slot):
	
	var board = NodeLoc.getBoard()
	
	for c in board.getAllCards():
		if c.cardNode.slot != slot and c.cardNode.slot != self.slot:
			c.onOtherBeforeDamage(self.slot, slot)
	
	
	if is_instance_valid(slot.cardNode):
		slot.cardNode.card.onBeforeDamage(self.slot, slot)
	card.onBeforeDamage(self.slot, slot)
	
	for c in board.getAllCards():
		if c.cardNode.slot != slot and c.cardNode.slot != self.slot:
			c.onOtherTakeDamage(self.slot, slot)
	
	for c in board.getAllCards():
		if c.cardNode.slot != slot and c.cardNode.slot != self.slot:
			c.onOtherDealDamage(self.slot, slot)
	
	while not NodeLoc.getBoard().getCanFight():
		fightingWait = true
		yield(get_tree().create_timer(0.1), "timeout")
	fightingWait = false
	
	
	if is_instance_valid(slot.cardNode):
		slot.cardNode.card.onTakeDamage(card)
		self.card.onTakeDamage(slot.cardNode.card)
		

	card.onDealDamage(slot)
	SoundEffectManager.playAttackSound()
	
	while not NodeLoc.getBoard().getCanFight():
		fightingWait = true
		yield(get_tree().create_timer(0.1), "timeout")
	fightingWait = false
	
	
	if is_instance_valid(slot.cardNode):
		
		if slot.cardNode.card.toughness <= 0:
			slot.cardNode.card.onKilledBy(self.slot)
			for c in NodeLoc.getBoard().getAllCards():
				c.onOtherKilled(slot)
			card.onKill(slot)
		if card.toughness <= 0:
			card.onKilledBy(slot.cardNode.card)
			slot.cardNode.card.onKill(self.slot)
			for c in NodeLoc.getBoard().getAllCards():
				c.onOtherKilled(self.slot)
	else:
		for p in NodeLoc.getBoard().players:
			if p.UUID == slot.playerID:
				var damage = max(card.power, 0)
				p.takeDamage(damage, self)
	
	for c in board.getAllCards():
		if c.cardNode.slot != slot and c.cardNode.slot != self.slot:
			c.onOtherAfterDamage(self.slot, slot)
	
	if is_instance_valid(slot.cardNode):
		slot.cardNode.card.onAfterDamage(self.slot, slot)
	card.onAfterDamage(self.slot, slot)
	
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
