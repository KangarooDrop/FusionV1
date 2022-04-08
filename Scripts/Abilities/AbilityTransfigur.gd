extends AbilityETB

class_name AbilityTransfigur

func _init(card : Card).("Transfigur", card, Color.blue, false, Vector2(0, 0)):
	pass
	
func onApplied(slot):
	addToStack("onEffect", [])
			
static func onEffect(params):
	for s in NodeLoc.getBoard().boardSlots:
		if is_instance_valid(s.cardNode) and s.cardNode.card != null:
			s.cardNode.card.power = 1
			s.cardNode.card.toughness = 1
			s.cardNode.card.maxToughness = 1

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creature is played, the power and health of all creatures are set to 1"
