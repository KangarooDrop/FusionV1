extends Node

func getBoard() -> Node:
	var b = null
	
	b = get_node_or_null("/root/main/CenterControl/Board")
	if b != null:
		return b
	
	b = get_node_or_null("/root/DeckEditor")
	if b != null:
		return b
	
	b = get_node_or_null("/root/Draft")
	if b != null:
		return b
	
	b = get_node_or_null("/root/DraftLobby")
	if b != null:
		return b
	
	b = get_node_or_null("/root/TournamentLobby")
	if b != null:
		return b
	
	return null
