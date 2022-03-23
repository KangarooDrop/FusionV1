extends Ability

class_name AbilityMadness

var buffsApplied := 0

func _init(card : Card).("Madness", card, Color.blue, true, Vector2(0, 0)):
	pass

func onDraw(card):
	onEffect()

func onMill(card):
	onEffect()

func onEffect():
	var pid = card.playerID
	for player in NodeLoc.getBoard().players:
		if player.UUID == pid:
			var num = player.deck.cards.size()
			var dif = num * count - buffsApplied
			card.power -= dif
			card.toughness -= dif
			card.maxToughness -= dif
			buffsApplied += dif
			break

func onRemove(ability):
	var pid = card.playerID
	for player in NodeLoc.getBoard().players:
		if player.UUID == pid:
			var num = player.deck.cards.size()
			var dif = num * count - buffsApplied
			card.power += dif
			card.toughness += dif
			card.maxToughness += dif
			buffsApplied -= dif
			break

func combine(abl : Ability):
	.combine(abl)
	var total = buffsApplied + abl.buffsApplied
	buffsApplied = total
	abl.buffsApplied = total

func clone(card : Card) -> Ability:
	var abl = .clone(card)
	abl.buffsApplied = buffsApplied
	return abl

func genDescription() -> String:
	return "This creature gets -" + str(count) + "/-" + str(count) + " for each card in your library"
