extends Ability

class_name AbilityInsignia

func _init(card : Card).("Insignia", card, Color.red, true, Vector2(0, 0)):
	pass

func onEnter(slot):
	.onEnter(slot)
	addToStack("onEffect", [card.playerID])
	card.removeAbility(self)
	
func onEnterFromFusion(slot):
	.onEnterFromFusion(slot)
	addToStack("onEffect", [card.playerID])
	card.removeAbility(self)
			
static func onEffect(params):
	for c in NodeLoc.getBoard().getAllCreatures():
		if c.playerID != params[0]:
			c.addAbility(AbilitySoulblaze.new(c))

func genDescription() -> String:
	return .genDescription() + "When this creature is played, inflict " + str(AbilitySoulblaze.new(null)) + " on all creatures. Removes this ability"
