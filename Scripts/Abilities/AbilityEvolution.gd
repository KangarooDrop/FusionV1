extends Ability

class_name AbilityEvolution

func _init(card : Card).("Evolution", "On fusion, the card gains +1/+1", card, Color.purple, true, Vector2(32, 64)):
	pass

func onFusion(card):
	card.power += count
	card.toughness += count

func combine(abl : Ability):
	.combine(abl)
	desc = "On fusion, the card gains +" + str(count) + "/+" + str(count) + " damage to you"
