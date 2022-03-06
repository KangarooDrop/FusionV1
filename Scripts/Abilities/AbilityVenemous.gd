extends Ability

class_name AbilityVenemous

func _init(card : Card).("Venemous", "Deals +2 damage to creatures", card, Color.brown, false, Vector2(16, 64)):
	pass

func combine(abl : Ability):
	.combine(abl)
	desc = "Deals +" + str(count * 2) + " damage to creatures"
