extends Ability

class_name AbilityMindrot

func _init(card : Card).("Mindrot", card, Color.blue, true, Vector2(0, 0)):
	pass

func onBeforeDamage(attacker, blocker):
	.onBeforeDamage(attacker, blocker)
	if attacker == card.cardNode.slot:
		addToStack("onEffect", [card.playerID, count])

static func onEffect(params):
	for p in NodeLoc.getBoard().players:
		if p.UUID != params[0]:
			for i in range(params[1]):
				p.deck.mill(p.UUID)

func genDescription() -> String:
	return .genDescription() + "When this creature attacks, remove the top " + str(count) + " cards of your opponent's deck from the game"
