extends Ability

class_name AbilityMolting

func _init(card : Card).("Molting", card, Color.brown, true, Vector2(32, 64)):
	pass

func onFusion(card):
	card.power += count
	card.toughness += count

func genDescription() -> String:
	return .genDescription() + "On fusion, this creature gets +" + str(count) + "/+" + str(count) + " damage to you"
