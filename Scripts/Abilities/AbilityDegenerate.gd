extends Ability

class_name AbilityDegenerate

func _init(card : Card).("Degenerate", card, Color.purple, false, Vector2(0, 0)):
	pass

func onFusion(card):
	card.creatureType = [Card.CREATURE_TYPE.Null]
	card.removeAbility(self)

func genDescription() -> String:
	return "On fusion, the card loses all creature types and becomes a null. Removes this ability"
