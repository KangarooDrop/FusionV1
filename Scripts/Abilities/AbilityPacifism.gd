extends Ability

class_name AbilityPacifism

func _init(card : Card).("Pacifism", card, Color.purple, false, Vector2(0, 0)):
	pass

func onEnter(slot):
	if not card.cantAttackSources.has(self):
		card.cantAttackSources.append(self)

func onFusion(card):
	for abl in card.abilities:
		if abl is get_script():
			card.removeAbility(abl)

func genDescription(subCount = 0) -> String:
	return .genDescription() + "This creature cannot attack. On fusion, removes this ability"
