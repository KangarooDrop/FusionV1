
class_name Ability

var name
var card : Card
var c : Color
var iconPos : Vector2

var showCount = false
var count = 1

func _init(name : String, card : Card, c : Color, showCount : bool, iconPos : Vector2):
	self.name = name
	self.card = card
	self.c = c
	self.showCount = showCount
	self.iconPos = iconPos

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
	
func onAttack(blocker):
	pass
	
func onBeingAttacked(attacker):
	pass

func onOtherAttack(attacker, blocker):
	pass

func onOtherBeingAttacked(attacker, blocker):
	pass

func onFusion(card):
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

func combine(abl : Ability):
	setCount(count + abl.count)

static func discardSelf(card):
	for i in range(NodeLoc.getBoard().players.size()):
		var p = NodeLoc.getBoard().players[i]
		if p.UUID == card.playerID:
			for j in range(p.hand.nodes.size()):
				if p.hand.nodes[j].card == card:
					p.hand.discardIndex(j)
					break
			break

func setCount(count : int) -> Ability:
	self.count = count
	return self

func getFileName():
	return self.get_script().get_path().get_file().get_basename()
	
func _to_string():
	return "[color=#" + c.to_html(false) +"][url=" + getFileName() + "||" + str(count) +"]" + name + (" "+str(count) if (showCount) else "") +"[/url][/color]"

func clone(card : Card) -> Ability:
	var abl = get_script().new(card)
	abl.count = count
	return abl

func genDescription() -> String:
	return "[color=#" + c.to_html(false) +"]" + name + (" "+str(count) if (showCount) else "") +":[/color]\n"

func addToStack(funcName : String, params : Array):
	NodeLoc.getBoard().abilityStack.append([get_script(), funcName, params])
