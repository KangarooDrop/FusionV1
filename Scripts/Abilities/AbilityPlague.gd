extends AbilityETB

class_name AbilityPlague

var selectedTypes := []
var affectedCards := []

func _init(card : Card).("Plague", card, Color.gold, true, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onETB", [])

func onETB(params : Array):
	NodeLoc.getBoard().getType(self, card.playerID)

func onTypeSelected(button : Button, key):
	if button == null:
		key = randi() % 6 + 2
	
	selectedTypes.append(key)
	onEffect(null)
	
	myVars.timesApplied = myVars.count
	
	NodeLoc.getBoard().endGetType()

func onOtherDeath(slot):
	removeEffect(slot)
	
func onOtherLeave(slot):
	removeEffect(slot)

func onDeath():
	var board = NodeLoc.getBoard()
	for p in board.players:
		for s in board.creatures[p.UUID]:
			if is_instance_valid(s.cardNode):
				removeEffect(s)
	selectedTypes.clear()
	
func onLeave():
	var board = NodeLoc.getBoard()
	for p in board.players:
		for s in board.creatures[p.UUID]:
			if is_instance_valid(s.cardNode):
				removeEffect(s)
	selectedTypes.clear()

func onOtherEnter(slot):
	onEffect(slot)

func onOtherEnterFromFusion(slot):
	onEffect(slot)

func onEffect(slot):
	var amt
	var board = NodeLoc.getBoard()
	var cards = []
	if slot == null:
		amt = myVars.count - myVars.timesApplied
		for p in board.players:
			for s in board.creatures[p.UUID]:
				if is_instance_valid(s.cardNode):
					cards.append(s.cardNode.card)
	else:
		amt = myVars.count
		if is_instance_valid(slot.cardNode):
			cards.append(slot.cardNode.card)
	
	for c in cards:
		if not c in affectedCards and board.isOnBoard(c):
			var found = false
			for t in selectedTypes:
				if t in c.creatureType:
					found = true
					break
			
			if found:
				affectedCards.append(c)
				c.power -= myVars.count
				c.toughness -= myVars.count
				c.maxToughness -= myVars.count

func removeEffect(slot):
	if is_instance_valid(slot.cardNode) and slot.cardNode.card in affectedCards:
		affectedCards.erase(slot.cardNode.card)
		slot.cardNode.card.power += myVars.count
		slot.cardNode.card.toughness += myVars.count
		slot.cardNode.card.maxToughness += myVars.count

	
func genDescription(subCount = 0) -> String:
	var ts = ""
	if selectedTypes.size() > 0:
		ts = "\n\tTypes: "
		for i in range(selectedTypes.size()):
			ts += Card.CREATURE_TYPE.keys()[selectedTypes[i]].capitalize()
			if i != selectedTypes.size() - 1:
				ts += ", "
	return .genDescription() + "When this creature is played, its controller chooses a creature type. Creatures of the chosen type(s) get -" + str(myVars.count) + "/-" + str(myVars.count)
