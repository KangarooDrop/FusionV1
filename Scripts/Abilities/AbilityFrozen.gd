extends Ability

class_name AbilityFrozen

var frozenThisTurn = false

var frozenOverlay = preload("res://Art/overlays/frozen.png")
var overlayAddedTo = null
var overlay = null

func _init(card : Card).("Frozen", card, Color.lightblue, false, Vector2(16, 0)):
	pass

func _physics_process(delta):
	if card != null:
		if overlayAddedTo != card.cardNode:
			if is_instance_valid(overlayAddedTo):
				overlay.queue_free()
				overlay = null
			overlayAddedTo = null
			
			if is_instance_valid(card.cardNode):
				overlay = Sprite.new()
				overlay.texture = frozenOverlay
				card.cardNode.get_node("Overlays").add_child(overlay)
				overlayAddedTo = card.cardNode
			else:
				card.cardNode = null

func onEnter(slot):
	.onEnter(slot)
	onEffect()

func onEnterFromFusion(slot):
	.onEnterFromFusion(slot)
	onEffect()

func onStartOfTurn():
	.onStartOfTurn()
	if NodeLoc.getBoard().isOnBoard(card):
		onEffect()
		if NodeLoc.getBoard().players[NodeLoc.getBoard().activePlayer].UUID == card.playerID:
			frozenThisTurn = true

func onEffect():
	if not card.cantAttackSources.has(self):
		card.cantAttackSources.append(self)
	card.canFuseThisTurn = false
	card.cardNode.setCardVisible(card.cardNode.getCardVisible())

func onEndOfTurn():
	if NodeLoc.getBoard().isOnBoard(card):
		if frozenThisTurn:
			card.canFuseThisTurn = true
			if NodeLoc.getBoard().players[NodeLoc.getBoard().activePlayer].UUID == card.playerID:
				var scr = get_script()
				for abl in card.abilities:
					if abl is scr:
						card.abilities.erase(abl)
						card.cantAttackSources.erase(self)
						overlay.queue_free()
						overlay = null
						break

func combine(abl : Ability):
	.combine(abl)
	frozenThisTurn = frozenThisTurn and abl.frozenThisTurn

func genDescription(subCount = 0) -> String:
	return .genDescription() + "This creature cannot attack or be fused until the end of its owners next turn"
