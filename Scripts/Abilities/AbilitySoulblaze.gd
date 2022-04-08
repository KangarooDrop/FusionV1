extends Ability

class_name AbilitySoulblaze

func _init(card : Card).("Soulblaze", card, Color.red, true, Vector2(32, 64)):
	pass

func onStartOfTurn():
	if NodeLoc.getBoard().isOnBoard(card) and NodeLoc.getBoard().players[NodeLoc.getBoard().activePlayer].UUID == card.playerID:
		addToStack("onStartEffect", [card, self])

func onDeath():
	.onDeath()
	addToStack("onDeathEffect", [card.playerID, count])

static func onStartEffect(params):
	params[0].toughness -= params[1].count
	params[1].setCount(params[1].count + 1)

static func onDeathEffect(params):
	for p in NodeLoc.getBoard().players:
		if p.UUID == params[0]:
			p.takeDamage(params[1], null)

func genDescription(subCount = 0) -> String:
	return .genDescription() + "At the start of your turn, this creature takes " + str(count) + " damage and increases its count by 1. When it dies, you take damage equal to the count"
