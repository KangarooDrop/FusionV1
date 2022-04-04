extends Ability

class_name AbilityUseless

func _init(card : Card).("Useless", card, Color.purple, false, Vector2(0, 0)):
	if card != null:
		card.canBePlayed = false

func onEnter(slot):
	card.removeAbility(self)

func onFusion(card):
	card.removeAbility(self)
	
func onEnterFromFusion(slot):
	card.removeAbility(self)

func genDescription() -> String:
	return .genDescription() + "Cannot be played"
