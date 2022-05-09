extends AbilityETB

class_name AbilityDaedalus

func _init(card : Card).("Daedalus", card, Color.lightgray, false, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onEffect", [])
			
func onEffect(params : Array):
	var cards = NodeLoc.getBoard().getAllCreatures()
	var highest = []
	for i in range(0, cards.size()):
		if highest.size() == 0 or cards[i].power == highest[0].power:
			highest.append(cards[i])
		elif cards[i].power > highest[0].power:
			highest = [cards[i]]
	for c in highest:
		c.isDying = true
		
	timesApplied = count

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creature is played, destroy all creatures with the highest power (if two or more creatures are tied, destroy all of them)"
