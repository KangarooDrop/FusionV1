extends Ability

class_name AbilityAmass

func _init(card : Card).("Amass", card, Color.gray, false, Vector2(0, 0)):
	pass

func onEnter(slot):
	.onEnter(slot)
	NodeLoc.getBoard().abilityStack.append([get_script(), "onEffect", [slot, count]])
	card.removeAbility(self)
	
func onEnterFromFusion(slot):
	.onEnterFromFusion(slot)
	NodeLoc.getBoard().abilityStack.append([get_script(), "onEffect", [slot, count]])
	card.removeAbility(self)
			
static func onEffect(params):
	var cardList := []
	for c in NodeLoc.getBoard().graveCards[params[0].playerID]:
		if c.creatureType == [6] and c.UUID != 61:
			cardList.append(c.clone())
	NodeLoc.getBoard().fuseToSlot(params[0], cardList)

func genDescription() -> String:
	return .genDescription() + "When this creature is played, fuse all mechs in your " + str(TextScrapyard.new(null)) + " to it. Removes this ability"
