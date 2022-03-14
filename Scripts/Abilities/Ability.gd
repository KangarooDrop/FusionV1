
class_name Ability

var name
var desc
var card
var c : Color
var iconPos : Vector2

var showCount = false
var count = 1

func _init(name : String, desc : String, card : Card, c : Color, showCount : bool, iconPos : Vector2):
	self.name = name
	self.desc = desc
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
	
func onAttack(blocker, board):
	pass
	
func onBeingAttacked(attacker, board):
	pass

func onFusion(card):
	pass
	
func onEnterFromFusion(board, slot):
	pass
	
func onOtherEnterFromFusion(board, slot):
	pass
	
func combine(abl : Ability):
	count += abl.count
	
func getFileName():
	return self.get_script().get_path().get_file().get_basename()
	
func _to_string():
	return "[color=#" + c.to_html(false) +"][url=" + getFileName() + "||" + str(count) +"]" + name + (" x"+str(count) if (showCount and count > 1) else "") +"[/url][/color]"

func clone(card : Card) -> Ability:
	var abl = get_script().new(card)
	abl.count = count
	return abl
