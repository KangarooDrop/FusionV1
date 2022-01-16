extends Node2D

var host = false
var online = false
var ip = "127.0.0.1"

var network
var DEFAULT_PORT = 25565
var MAX_PEERS = 1

var playerData = {}
	
func _OnConnectFailed():
	print("failed to connect to server")
	
func _OnConnectSucceeded():
	print("connected to server")
	
	get_node("/root/Lobby").startGame()


func startServer():
	network = NetworkedMultiplayerENet.new()
	network.create_server(DEFAULT_PORT, MAX_PEERS)
	get_tree().set_network_peer(network)
	print("Server started")
	
	get_tree().connect("network_peer_connected", self, "playerConnected")
	get_tree().connect("network_peer_disconnected", self, "playerDisconnected")
	
func closeServer():
	network.close_connection()
	online = false
	host = false
	
func playerConnected(player_id):
	print("User "+ str(player_id) + " Connected")
	playerData[player_id] = null
	
	get_node("/root/Lobby").startGame()

	
func playerDisconnected(player_id):
	print("User "+ str(player_id) + " Disconnected")
	playerData.erase(player_id)

####################################################################
	
func connectToServer():
	get_tree().connect("connection_failed", self, "_OnConnectFailed")
	get_tree().connect("connected_to_server", self, "_OnConnectSucceeded")
	
	network = NetworkedMultiplayerENet.new()
	
	playerData = {}
	
	var errorStatus = network.create_client(ip, DEFAULT_PORT)
	print("Trying to connect results in code #" + str(errorStatus))
	get_tree().set_network_peer(network)
	
