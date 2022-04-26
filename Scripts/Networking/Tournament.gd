extends Node

var startingOrder = null
var tree : TTree

var currentWins : int = 0
var currentLosses : int = 0
var gamesPerMatch : int = 3

var lastGameLoss : bool = false
var lastGameWin  : bool = false

var hasLost = false

func startTournament(order):
	hasLost = false
	tree = TTree.new(order)

func addWin():
	lastGameWin = true
	currentWins += 1
	if (currentWins * 2) / gamesPerMatch > 0:
		Server.setTournamentWinner(get_tree().get_network_unique_id())

func addLoss():
	lastGameLoss = true
	currentLosses += 1
	if (currentLosses * 2) / gamesPerMatch > 0:
		hasLost = true

func hasLost(player_id, node=tree.root) -> bool:
	if node.l_child != null and node.l_child.data == player_id and node.data != -1:
		return node.data == node.r_child.data
	elif node.r_child != null and node.r_child.data == player_id and node.data != -1:
		return node.data == node.l_child.data
	
	if node.l_child != null:
		if hasLost(player_id, node.l_child):
			return true
			
	if node.r_child != null:
		if hasLost(player_id, node.r_child):
			return true
	
	return false

func isWaiting(player_id):
	return getOpponent(player_id) == -1

func replaceWith(data, dataNew, node=tree.root):
	if node.data == data:
		node.data = dataNew
	if node.l_child != null:
		replaceWith(data, dataNew, node.l_child)
	if node.r_child != null:
		replaceWith(data, dataNew, node.r_child)

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
			node.l_child = null
			node.r_child = null
			return
	elif node.l_child.data == -1 and node.r_child.data != -1:
		if node.l_child.hasNoChildren() and node.r_child.hasNoChildren():
			node.data = node.r_child.data
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
		return true
	elif node.r_child.data == player_id:
		node.data = node.r_child.data
		return true
	else:
		if setWinner(player_id, node.l_child):
			return true
		elif setWinner(player_id, node.r_child):
			return true
		else:
			return false

func getOpponent(player_id, node = tree.root) -> int:
	if node.l_child != null and node.l_child.data == player_id:
		return node.r_child.data
	elif node.r_child != null and node.r_child.data == player_id:
		return node.l_child.data
	
	if node.l_child != null:
		var rtn = getOpponent(player_id, node.l_child)
		if rtn != -2:
			return rtn
			
	if node.r_child != null:
		var rtn = getOpponent(player_id, node.r_child)
		if rtn != -2:
			return rtn
	
	return -2

class TTree:
	var root : TTreeData = null
	
	func _init(order : Array):
		var t = 1
		while t < order.size():
			t *= 2
		if t != order.size():
			print(" *** ERROR: TTree must be initialized with a number of nodes equal to 2^n")
		else:
			var layer = order.duplicate()
			while layer.size() > 1:
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
					
					layerNew.append(p_node)
					
				layer = layerNew
			if layer[0] is TTreeData:
				root = layer[0]
			else:
				root = TTreeData.new(layer[0])
	
	func getHeight(node=root) -> int:
		var total = 1
		var lLen = 0
		var rLen = 0
		
		if node.l_child != null:
			lLen += getHeight(node.l_child)
		if node.r_child != null:
			rLen += getHeight(node.r_child)
		
		if lLen > rLen:
			total += lLen
		else:
			total += rLen
		
		return total
	
	func getNodesAtHeight(height, node=root, currentHeight = 0) -> Array:
		if height == currentHeight:
			return [node]
		elif height > currentHeight:
			var rtn = []
			if node.l_child != null:
				rtn += getNodesAtHeight(height, node.l_child, currentHeight + 1)
			if node.r_child != null:
				rtn += getNodesAtHeight(height, node.r_child, currentHeight + 1)
			return rtn
		else:
			return []
	
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
