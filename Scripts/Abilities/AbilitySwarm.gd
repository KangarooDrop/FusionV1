extends Ability

class_name AbilitySwarm

var buffsApplied = 0

func _init(card : Card).("Sworm", card, Color.brown, true, Vector2(16, 48)):
	pass

func onEnter(slot):
	onEffect()

func onEnterFromFusion(slot):
	onEffect()

func onOtherEnter(slot):
	onEffect()

func onOtherEnterFromFusion(slot):
	onEffect()

func onOtherLeave(slot):
	onEffect()

func onEffect():
	var buffsNew = 0
	var board = NodeLoc.getBoard()
	
	if board.isOnBoard(card):
		for p in board.players:
			for s in board.creatures[p.UUID]:
				if is_instance_valid(s.cardNode) and ListOfCards.hasAbility(s.cardNode.card, get_script()) and (s.cardNode.card.toughness > 0 or s.cardNode.card == card):
					buffsNew += 1
		
		self.card.power += buffsNew - buffsApplied
		self.card.toughness += buffsNew - buffsApplied
		self.card.maxToughness += buffsNew - buffsApplied
		buffsApplied = buffsNew
	
func clone(card : Card) -> Ability:
	var abl = .clone(card)
	abl.buffsApplied = buffsApplied
	return abl

func combine(abl : Ability):
	.combine(abl)
	abl.buffsApplied += buffsApplied

func genDescription() -> String:
	return .genDescription() + "Get +" + str(count) + "/+" + str(count) + " for each creature with " + name
