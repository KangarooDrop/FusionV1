extends Ability

class_name AbilityFrozen

var frozenThisTurn = false

var frozenOverlay = preload("res://Art/overlays/frozen.png")
var overlay = null

func _init(card : Card).("Frozen", card, Color.lightblue, false, Vector2(16, 0)):
	pass

func _physics_process(delta):
	if not is_instance_valid(overlay) and card != null and is_instance_valid(card.cardNode):
		overlay = Preloader.overlayScene.instance().setTexture(frozenOverlay).setSource(self).setDestroyOnRemove(true)
		card.cardNode.get_node("Overlays").add_child(overlay)

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
				card.abilities.erase(self)
				card.cantAttackSources.erase(self)
				card = null

func combine(abl : Ability):
	.combine(abl)
	frozenThisTurn = frozenThisTurn and abl.frozenThisTurn

func genDescription(subCount = 0) -> String:
	return .genDescription() + "This creature cannot attack or be fused until the end of its owners next turn"
