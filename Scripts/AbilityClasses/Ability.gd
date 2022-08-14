
class_name Ability

var name
var card : Card
var c : Color
var iconPos : Vector2

var showCount = false

var myVars : Dictionary = {}

func _init(name : String, card : Card, c : Color, showCount : bool, iconPos : Vector2):
	self.name = name
	self.card = card
	self.c = c
	self.showCount = showCount
	self.iconPos = iconPos
	self.setCount(1)

func _physics_process(delta):
	pass

func onHoverEnter(slot):
	pass

func onHoverExit(slot):
	pass

func onEnter(slot):
	pass
	
func onOtherEnter(slot):
	pass
	
func onOtherDeath(slot):
	pass
	
func onOtherLeave(slot):
	pass
	
func onDeath():
	pass
	
func onLeave():
	pass
	
func onStartOfTurn():
	pass

func onEndOfTurn():
	pass

func onFusion():
	pass
	
func onEnterFromFusion(slot):
	pass
	
func onOtherEnterFromFusion(slot):
	pass

func onDraw(card):
	pass

func onMill(card):
	pass

func onGraveAdd(card):
	pass

func onRemove(ability):
	pass

func onKill(slot):
	pass

func onKilledBy(slot):
	pass

func onOtherKilled(slot):
	pass

func onBeforeDamage(attacker, blocker):
	pass

func onAfterDamage(attacker, blocker):
	pass

func onOtherBeforeDamage(attacker, blocker):
	pass

func onOtherAfterDamage(attacker, blocker):
	pass

func onTakeDamage(card):
	pass

func onDealDamage(slot):
	pass

func onOtherTakeDamage(attacker, blocker):
	pass

func onOtherDealDamage(attacker, blocker):
	pass

func onBeforeCombat(attacker, blockers):
	pass

func onAfterCombat(attacker, blockers):
	pass

func onAdjustCost(card) -> int:
	return 0

func onCardsPlayed(slot, cards):
	pass

func onOtherActivate(abl):
	pass

func onTypeSelected(button : Button, key):
	pass

func checkWaiting() -> bool:
	return true

func combine(abl : Ability):
	setCount(myVars.count + abl.myVars.count)

static func discardSelf(card, addCardToGrave = true):
	for i in range(NodeLoc.getBoard().players.size()):
		var p = NodeLoc.getBoard().players[i]
		if p.UUID == card.playerID:
			for j in range(p.hand.nodes.size()):
				if p.hand.nodes[j].card == card:
					p.hand.discardIndex(j, addCardToGrave)
					break
			break

func setCount(countNew : int) -> Ability:
	myVars.count = countNew
	return self

func setName(name : String) -> Ability:
	self.name = name
	return self

func getFileName():
	return self.get_script().get_path().get_file().get_basename()
	
func _to_string():
	var cardString = ""
	if card != null:
		cardString += "||" + str(card.UUID)
	return "[color=#" + c.to_html(false) +"][url=desc||" + getFileName() + "||" + str(myVars.count) + cardString + "]" + name + (" "+str(myVars.count) if (showCount) else "") +"[/url][/color]"

func clone(card : Card) -> Ability:
	var abl = get_script().new(card)
	abl.myVars = myVars.duplicate(true)
	return abl
	
func cloneBase(card : Card) -> Ability:
	var abl = get_script().new(card)
	abl.setCount(myVars.count)
	return abl

func serialize() -> String:
	var rtn = ""
	rtn += get_script().get_path().get_basename().get_file() + " " + str(myVars.count)
	for k in myVars.keys():
		rtn += " " + k + "=" + str(myVars[k])
	return rtn

func genDescription(subCount = 0) -> String:
	return "[color=#" + c.to_html(false) +"]" + name + (" "+str(myVars.count - subCount) if (showCount) else "") +":[/color]\n"

func genStackDescription(subCount) -> String:
	return genDescription(subCount)

func addToStack(funcName : String, params : Array, forceWait = false, canAttack = false):
	var data = \
	{
		"source":self,
		"funcName":funcName,
		"params":params,
		"triggered":false,
		"canAttack":canAttack
	}
	NodeLoc.getBoard().abilityStack.add(data)
	if forceWait:
		NodeLoc.getBoard().waitingAbilities.append(self)

func addDelayedAbility():
	var board = NodeLoc.getBoard()
	var card = board.delayedAbilityCards[self.card.playerID]
	card.addAbility(self.clone(card))
