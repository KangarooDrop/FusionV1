extends Ability

class_name AbilityDegenerate

func _init(card : Card).("Degenerate", "On fusion, the card loses all creature types and becomes a null. Removes this ability", card):
	pass

func onFusion(card):
	card.creatureType = [CardCreature.CREATURE_TYPE.Null]
	var scr = get_script()
	for abl in card.abilities:
		if abl is scr:
			card.abilities.erase(abl)
			break
