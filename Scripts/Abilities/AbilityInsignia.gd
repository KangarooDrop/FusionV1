extends AbilityETB

class_name AbilityInsignia

func _init(card : Card).("Insignia", card, Color.red, true, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onEffect", [card.playerID, count - timesApplied])
			
static func onEffect(params):
	for c in NodeLoc.getBoard().getAllCreatures():
		if c.playerID != params[0]:
			c.addAbility(AbilitySoulblaze.new(c).setCount(params[1]))

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creature is played, inflict " + str(AbilitySoulblaze.new(null).setCount(count -  - subCount)) + " on all opposing creatures"
