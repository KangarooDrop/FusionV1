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
	for i in range(params[1]):
		var card = ListOfCards.getCard(5)
		for abl in card.abilities.duplicate():
			card.removeAbility(abl)
		params[0].addCreatureToBoard(card, null)

func genDescription() -> String:
	var string = "a"
	if count > 1:
		string = str(count)
	return .genDescription() + "When this creature is played, create " + string +" 1/1 mech with no abilities. Removes this ability"
