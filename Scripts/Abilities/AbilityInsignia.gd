extends AbilityETB

class_name AbilityInsignia

func _init(card : Card).("Insignia", card, Color.red, false, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onEffect", [])
			
func onEffect(params):
	for c in NodeLoc.getBoard().getAllCreatures():
		c.addAbility(AbilitySoulblaze.new(c))
	myVars.timesApplied = myVars.count

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creature is played, inflict " + str(AbilitySoulblaze.new(null)) + " on all creatures"
