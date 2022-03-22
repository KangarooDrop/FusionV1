
class_name Ability

var name
var desc
var card : Card
var c : Color
var iconPos : Vector2

var showCount = false
var count = 1

func _init(name : String, card : Card, c : Color, showCount : bool, iconPos : Vector2):
	self.name = name
	self.desc = genDescription()
	self.card = card
	self.c = c
	self.showCount = showCount
	self.iconPos = iconPos

func onEnter(board, slot):
	pass
	
func onOtherEnter(board, slot):
	pass
	
func onOtherDeath(board, slot):
	pass
	
func onOtherLeave(board, slot):
	pass
	
func onDeath(board):
	pass
	
func onLeave(board):
	pass
	
func onStartOfTurn(board):
	pass

func onEndOfTurn(board):
	pass
	
func onAttack(board, blocker):
	pass
	
func onBeingAttacked(board, attacker):
	pass

func onOtherAttack(board, attacker, blocker):
	pass

func onOtherBeingAttacked(board, attacker, blocker):
	pass

func onFusion(card):
	pass
	
func onEnterFromFusion(board, slot):
	pass
	
func onOtherEnterFromFusion(board, slot):
	pass

func onDraw(board, card):
	pass

func onMill(board, card):
	pass

func onGraveAdd(board, card):
	pass

func combine(abl : Ability):
	setCount(count + abl.count)

static func discardSelf(board, card):
	for i in range(board.players.size()):
		var p = board.players[i]
		if p.UUID == card.playerID:
			for j in range(p.hand.nodes.size()):
				if p.hand.nodes[j].card == card:
					p.hand.discardIndex(j)
					break
			break

func setCount(count : int):
	self.count = count
	desc = genDescription()

func getFileName():
	return self.get_script().get_path().get_file().get_basename()
	
func _to_string():
	return "[color=#" + c.to_html(false) +"][url=" + getFileName() + "||" + str(count) +"]" + name + (" "+str(count) if (showCount) else "") +"[/url][/color]"

func clone(card : Card) -> Ability:
	var abl = get_script().new(card)
	abl.count = count
	return abl

func genDescription() -> String:
	return ""
