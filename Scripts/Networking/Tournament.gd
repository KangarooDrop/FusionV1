extends Node

var startingOrder = null
var tree : TTree

var currentWins : int = 0
var currentLosses : int = 0
var gamesPerMatch : int = 3

func startTournament(order):
	tree = TTree.new(order)

func addWin():
	currentWins += 1
	if (currentWins * 2) / gamesPerMatch > 0:
		Server.setTournamentWinner(get_tree().get_network_unique_id())

func addLoss():
	currentLosses += 1

func replaceWith(data, dataNew):
	for n in tree.nodes:
		if n.data == data:
			n.data = dataNew

func genTournamentOrder(players : Array) -> Array:
	var order = players.duplicate()
	order.shuffle()
	
	var total = 1
	while total < order.size():
		total *= 2
	
	for i in range(total - players.size()):
		order.insert(players.size() - i, -1)
	
	return order

func trimBranches(node : TTreeData = tree.root):
	if node.hasNoChildren():
		return
	elif node.l_child.data != -1 and node.r_child.data == -1:
		if node.l_child.hasNoChildren() and node.r_child.hasNoChildren():
			node.data = node.l_child.data
			tree.nodes.erase(node.l_child)
			tree.nodes.erase(node.r_child)
			node.l_child = null
			node.r_child = null
			return
	elif node.l_child.data == -1 and node.r_child.data != -1:
		if node.l_child.hasNoChildren() and node.r_child.hasNoChildren():
			node.data = node.r_child.data
			tree.nodes.erase(node.l_child)
			tree.nodes.erase(node.r_child)
			node.l_child = null
			node.r_child = null
			return
	
	if node.l_child != null:
		trimBranches(node.l_child)
	if node.r_child != null:
		trimBranches(node.r_child)

func setWinner(player_id, node=tree.root) -> bool:
	if node.l_child == null or node.r_child == null:
		return false
	if node.l_child.data == player_id:
		node.data = node.l_child.data
		tree.nodes.erase(node.l_child)
		tree.nodes.erase(node.r_child)
		node.l_child = null
		node.r_child = null
		return true
	elif node.r_child.data == player_id:
		node.data = node.r_child.data
		tree.nodes.erase(node.l_child)
		tree.nodes.erase(node.r_child)
		node.l_child = null
		node.r_child = null
		return true
	else:
		if setWinner(player_id, node.l_child):
			return true
		elif setWinner(player_id, node.r_child):
			return true
		else:
			return false

func getOpponent(player_id) -> int:
	for n in tree.nodes:
		if n.l_child != null and n.r_child != null:
			if n.l_child.data == player_id:
				return n.r_child.data 
			elif n.r_child.data == player_id:
				return n.l_child.data
	return -2

#trim function () - traverses tree and moves up any player is facing an opponent not in Server.playerIDs and only if the node has no children

#getOpponent function (player_id) - finds node w data=player_id and returns the sibling

#setWinner function (player_id) - finds node w a child's data=player_id, removes the children and sets its data to player_id

class TTree:
	var root : TTreeData = null
	var nodes : Array = []
	
	func _init(order : Array):
		var t = 1
		while t < order.size():
			t *= 2
		if t != order.size():
			print(" *** ERROR: TTree must be initialized with a number of nodes equal to 2^n")
		else:
			var layer = order.duplicate()
			while layer.size() > 1:
				print(layer)
				var layerNew = []
				for i in range(0, layer.size(), 2):
					var p_node = TTreeData.new(-1)
					var l_node
					if layer[i] is TTreeData:
						l_node = layer[i]
					else:
						l_node =  TTreeData.new(layer[i])
					var r_node
					if layer[i+1] is TTreeData:
						r_node = layer[i+1]
					else:
						r_node =  TTreeData.new(layer[i+1])
					
					p_node.l_child = l_node
					p_node.r_child = r_node
					l_node.parent = p_node
					r_node.parent = p_node
					
					nodes.append(l_node)
					nodes.append(r_node)
					
					layerNew.append(p_node)
					
				layer = layerNew
			root = layer[0]
			nodes.append(root)
	
	func _to_string():
		return str(root)
	
class TTreeData:
	var data = null
	var parent : TTreeData = null
	var l_child : TTreeData = null
	var r_child : TTreeData = null
	
	func _init(data = null):
		self.data = data
	
	func hasNoChildren():
		return l_child == null and r_child == null
	
	func hasChild(data):
		return l_child.data == data or r_child.data == data
	
	func _to_string():
		var rtn = str(data) + ": ["
		if l_child != null:
			rtn += str(l_child)
		else:
			rtn += " "
		rtn += ", "
		if r_child != null:
			rtn += str(r_child)
		else:
			rtn += " "
		rtn += "]"
		return rtn
