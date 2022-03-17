extends Ability

class_name TextArmor

var frozenThisTurn = false

func _init(card : Card).("Armor", card, Color.brown, false, Vector2(0, 0)):
	pass

func genDescription() -> String:
	return "Prevents damage to life"
