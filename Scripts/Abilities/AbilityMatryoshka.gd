extends Ability

class_name AbilityMatryoshka

func _init(card : Card).("Matryoshka", card, Color.darkgray, true, Vector2(32, 96)):
	pass

func onDeath():
	.onDeath()
	NodeLoc.getBoard().abilityStack.append([get_script(), "onEffect", [card, count]])

static func onEffect(params):
	var hand = null
	for p in NodeLoc.getBoard().players:
		if p.UUID == params[0].playerID:
			for i in range(params[1]):
				p.hand.addCardToHand([ListOfCards.getCard(57), true, false])
			break

func genDescription() -> String:
	return .genDescription() + "When this creature dies, add " + str(count) + " " + str(TextSkinShedder.new(null)) +" to your hand"
