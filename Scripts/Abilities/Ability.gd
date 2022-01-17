
class_name Ability

var name
var desc
var card

func _init(name : String, desc : String, card : Card):
	self.name = name
	self.desc = desc
	self.card = card

func onEnter(board):
	pass
	
func onDeath(board):
	pass
	
func onStartOfTurn(board):
	pass

func onEndOfTurn(board):
	pass
	
func onAttack(blocker, board):
	pass
	
func onBeingAttacked(attacker, board):
	pass
