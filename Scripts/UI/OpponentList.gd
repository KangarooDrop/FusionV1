extends Control

signal close

func _ready():
	pass

func show():
	.show()
	
	clearOpponents()
	
	var label = Label.new()
	NodeLoc.setLabelParams(label)
	label.clip_text = true
	label.text = "Opponents:"
	label.rect_min_size.x = 200
	
	$VBoxContainer.add_child(label)
	$VBoxContainer.add_child(Control.new())
	$VBoxContainer.add_child(Control.new())
	$VBoxContainer.add_child(Control.new())
	
	for player_id in Server.playerIDs:
		var name = Server.playerNames[player_id]
		label = Label.new()
		NodeLoc.setLabelParams(label)
		label.clip_text = true
		label.text = name
		label.rect_min_size.x = 200
		label.rect_min_size.y = 24
		
		$VBoxContainer.add_child(label)
		
		var button = Button.new()
		NodeLoc.setButtonParams(button)
		if Server.opponentID == player_id:
			button.text = "Challenge"
			button.disabled = true
		else:
			if Server.playersChallenged[player_id]:
				button.text = "Revoke"
			else:
				button.text = "Challenge"
				
		button.connect("pressed", self, "opponentButtonPressed", [player_id, button])
		
		label.add_child(button)
		button.rect_position.x = label.rect_size.x - button.rect_size.x
	
	if get_node_or_null("/root/main") != null:
		$VBoxContainer.add_child(Control.new())
		$VBoxContainer.add_child(Control.new())
		$VBoxContainer.add_child(Control.new())
	
		var button = Button.new()
		NodeLoc.setButtonParams(button)
		button.text = "Back"
		button.connect("pressed", self, "hide")
		$VBoxContainer.add_child(button)
	
	resize()

func hide():
	emit_signal("close")
	.hide()

func resize():
	yield(get_tree(), "idle_frame")
	$VBoxContainer.rect_size = Vector2()
	$VBoxContainer.set_anchors_and_margins_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)
	
	$VBoxContainer.rect_size = Vector2()
	$NinePatchRect.rect_size = $VBoxContainer.rect_size + Vector2(32, 32)
	$NinePatchRect.set_anchors_and_margins_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)

func opponentButtonPressed(player_id, button):
	if Server.playersChallenged.has(player_id):
		if Server.playersChallenged[player_id]:
			Server.playersChallenged[player_id] = false
			button.text = "Challenge"
		else:
			Server.challengeOpponent(player_id)
			button.text = "Revoke"
	else:
		button.get_parent().queue_free()
		

func clearOpponents():
	for c in $VBoxContainer.get_children():
		c.queue_free()
