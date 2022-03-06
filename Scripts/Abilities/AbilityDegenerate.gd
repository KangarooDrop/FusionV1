extends Ability

class_name AbilityDegenerate

func _init(card : Card).("Degenerate", "On fusion, the card loses all creature types and becomes a null. Removes this ability", card, Color.purple, false, Vector2(0, 0)):
	pass

func onFusion(card):
	card.creatureType = [Card.CREATURE_TYPE.Null]
	card.abilities.erase(self)
