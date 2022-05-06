extends Ability

class_name AbilityMolting

func _init(card : Card).("Molting", card, Color.brown, true, Vector2(32, 64)):
	pass

func onFusion():
	card.power += count
	card.toughness += count

func genDescription(subCount = 0) -> String:
	return .genDescription() + "On fusion, this creature gets +" + str(count) + "/+" + str(count)
