extends Ability

class_name AbilityMindrot

func _init(card : Card).("Mindrot", card, Color.blue, true, Vector2(0, 0)):
	pass

func onEnter(slot):
	.onEnter(slot)
	addToStack("onEffect", [card.playerID, count])
	card.removeAbility(self)
	
func onEnterFromFusion(slot):
	.onEnterFromFusion(slot)
	addToStack("onEffect", [card.playerID, count])
	card.removeAbility(self)

static func onEffect(params):
	for p in NodeLoc.getBoard().players:
		if p.UUID != params[0]:
			for i in range(params[1]):
				p.deck.mill(p.UUID)

func genDescription() -> String:
	return .genDescription() + "When this creature is played, remove the top " + str(count) + " cards of your opponent's deck from the game"
