extends Ability

class_name AbilityComposite

var buffsApplied = 0

func _init(card : Card).("Composite", card, Color.gray, true, Vector2(0, 80)):
	pass

func onDraw(card):
	if card == self.card:
		for i in range(count - buffsApplied):
			onEffect()
			buffsApplied += 1

func onEffect():
	for s in NodeLoc.getBoard().creatures[card.playerID]:
		if is_instance_valid(s.cardNode) and (is_instance_valid(card.cardNode.slot) and s != card.cardNode.slot):
			card.power += 1

func onOtherEnter(slot):
	if slot.playerID == card.playerID:
		card.power += count

func onOtherEnterFromFusion(slot):
	if slot.playerID == card.playerID:
		card.power += count
	
func onOtherLeave(slot):
	if slot.playerID == card.playerID:
		card.power -= count
	
func clone(card : Card) -> Ability:
	var abl = .clone(card)
	abl.buffsApplied = buffsApplied
	return abl
	
func combine(abl : Ability):
	.combine(abl)
	abl.buffsApplied += buffsApplied

func genDescription() -> String:
	return "Gains +" + str(count) + " power for each other creature you control"
