
class_name Ability

var name
var desc
var card

func _init(name : String, desc : String, card : Card):
	self.name = name
	self.desc = desc
	self.card = card

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
	
func _to_string():
	return name + " - " + desc
