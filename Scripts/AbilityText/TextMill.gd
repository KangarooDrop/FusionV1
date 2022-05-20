extends Ability

class_name TextMill

func _init(card : Card).("Mill", card, Color.blue, false, Vector2(0, 0)):
	pass

func setCount(count : int) -> Ability:
	.setCount(count)
	if count == 1:
		name = "Mill 1"
	else:
		name = "Mills " + str(count)
	
	return self

func genDescription(subCount = 0) -> String:
	return .genDescription() + "Put the top " + str(myVars.count) + " cards of your deck into your " + str(TextScrapyard.new(null))
