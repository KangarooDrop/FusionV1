extends Ability

class_name AbilityMindrot

func _init(card : Card).("Mindrot", card, Color.blue, true, Vector2(0, 0)):
	pass

func onBeforeDamage(attacker, blocker):
	.onBeforeDamage(attacker, blocker)
	if attacker == card.cardNode.slot:
		addToStack("onEffect", [])

func onEffect(params):
	for p in NodeLoc.getBoard().players:
		if p.UUID != card.playerID:
			for i in range(count):
				p.deck.mill(p.UUID)

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creature attacks, its controller's opponent " + str(TextMill.new(null).setCount(count))
