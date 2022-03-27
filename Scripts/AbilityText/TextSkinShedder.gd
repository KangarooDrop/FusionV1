extends Ability

class_name TextSkinShedder

var mat = load("res://Scripts/Abilities/AbilityMatryoshka.gd")

func _init(card : Card).("Skin Shedder", card, Color.darkgray, false, Vector2(0, 0)):
	pass

func genDescription() -> String:
	return .genDescription() + "A 1/1 necro with " + str(mat.new(null).setCount(2))
