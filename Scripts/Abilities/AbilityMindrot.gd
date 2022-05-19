extends Ability

class_name AbilityMindrot

func _init(card : Card).("Mindrot", card, Color.blue, false, Vector2(0, 0)):
	pass

func onBeforeDamage(attacker, blocker):
	.onBeforeDamage(attacker, blocker)
	if attacker == card.cardNode.slot:
		addToStack("onEffect", [])

func onEffect(params):
	for p in NodeLoc.getBoard().players:
		if p.UUID != card.playerID:
			for i in range(card.power):
				p.deck.mill(p.UUID)

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creature attacks, its opponent " + str(TextMill.new(null).setName("Mills")) + " equal to this creature's power"
