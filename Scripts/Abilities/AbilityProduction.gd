extends Ability

class_name AbilityProduction

func _init(card : Card).("Production", card, Color.gray, true, Vector2(0, 0)):
	pass

func onEnter(slot):
	.onEnter(slot)
	NodeLoc.getBoard().abilityStack.append([get_script(), "onEffect", [card, count]])
	card.removeAbility(self)
	
func onEnterFromFusion(slot):
	.onEnterFromFusion(slot)
	NodeLoc.getBoard().abilityStack.append([get_script(), "onEffect", [card, count]])
	card.removeAbility(self)

static func onEffect(params):
	var hand = null
	for p in NodeLoc.getBoard().players:
		if p.UUID == params[0].cardNode.slot.playerID:
			for i in range(params[1]):
				p.hand.addCardToHand([ListOfCards.getCard(5), true, false])
			break
	
func genDescription() -> String:
	var string = "a mech"
	if count > 1:
		string = str(count) + " mechs"
	return "When this creature is played, add " + string + " to your hand. Removes this ability"
