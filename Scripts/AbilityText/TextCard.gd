extends Ability

class_name TextCard

func _init(card : Card).(card.name, card, Color.gray, false, Vector2()):
	pass

func genDescription(subCount = 0) -> String:
	var typeString = ""
	for i in range(card.creatureType.size()):
		if i != 0:
			typeString += "/"
		typeString += Card.CREATURE_TYPE.keys()[card.creatureType[i]]
	
	var abilityString = ""
	if card.abilities.size() > 0:
		abilityString += " with "
	for i in range(card.abilities.size()):
		if i != 0:
			if i == card.abilities.size()-1:
				abilityString += " and "
			else:
				abilityString += ", "
		var abl = card.abilities[i]
		abilityString += str(abl.get_script().new(null).setCount(abl.count))
	
	return .genDescription() + "A " + str(card.power) + "/" + str(card.toughness) + " " + typeString + abilityString
