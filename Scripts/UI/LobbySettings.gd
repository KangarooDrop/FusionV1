extends Control

signal close

func _ready():
	for k in Settings.GAME_TYPES.keys():
		$VBoxContainer/GameTypeHbox/OptionButton.add_item(k.capitalize())
	for k in Settings.MATCH_TYPE.keys():
		$VBoxContainer/MatchTypeHbox/OptionButton.add_item(k.capitalize())
	for k in Settings.DRAFT_TYPES.keys():
		$VBoxContainer/DraftTypeHbox/OptionButton.add_item(k.capitalize())
	
	$VBoxContainer/GameTypeHbox/OptionButton.select(0)
	$VBoxContainer/GameTypeHbox/OptionButton.emit_signal("item_selected", 0)
	
	$VBoxContainer/DraftTypeHbox/OptionButton.select(0)
	$VBoxContainer/DraftTypeHbox/OptionButton.emit_signal("item_selected", 0)
	
	$VBoxContainer/MatchTypeHbox/OptionButton.select(0)
	$VBoxContainer/MatchTypeHbox/OptionButton.emit_signal("item_selected", 0)
	
	for t in Settings.TURN_TIMES.values():
		var string = ""
		if t == -1:
			string = "No limit"
		else:
			string = TurnTimer.intToTime(t)
		$VBoxContainer/TurnTimer/OptionButton.add_item(string)
	$VBoxContainer/TurnTimer/OptionButton.select(Settings.TURN_TIMES.values().find(Settings.turnTimerMax))
	
	for t in Settings.GAME_TIMES.values():
		var string = ""
		if t == -1:
			string = "No limit"
		else:
			string = TurnTimer.intToTime(t)
		$VBoxContainer/GameTimer/OptionButton.add_item(string)
	$VBoxContainer/GameTimer/OptionButton.select(Settings.GAME_TIMES.values().find(Settings.gameTimerMax))

func resizeSelf():
	$VBoxContainer.rect_size = Vector2(0, 0)
	$VBoxContainer.set_anchors_and_margins_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)
	
	yield(get_tree(), "idle_frame")
	$NinePatchRect.rect_size = $VBoxContainer.rect_size + Vector2(16, 16)
	$NinePatchRect.set_anchors_and_margins_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)

func show():
	resizeSelf()
	.show()

func onGameTypeSelected(index):
	if index == Settings.GAME_TYPES.CONSTRUCTED:
		$VBoxContainer/PlayerNum.text = "Players Required: 2"
		
		$VBoxContainer/DraftTypeHbox.visible = false
		$VBoxContainer/PacksHbox.visible = false
	elif index == Settings.GAME_TYPES.DRAFT:
		Settings.selectedDeck = ".draft.json"
		onDraftTypeSelected($VBoxContainer/DraftTypeHbox/OptionButton.selected)
		
		$VBoxContainer/DraftTypeHbox.visible = true
		$VBoxContainer/PacksHbox.visible = true
		
	resizeSelf()

func onDraftTypeSelected(index):
	if $VBoxContainer/GameTypeHbox/OptionButton.selected == Settings.GAME_TYPES.DRAFT:
		match index:
			Settings.DRAFT_TYPES.WINSTON:
				$VBoxContainer/PlayerNum.text = "Players Recommended: 2-3"
			
			Settings.DRAFT_TYPES.BOOSTER:
				$VBoxContainer/PlayerNum.text = "Players Recommended: 3+"
			
			Settings.DRAFT_TYPES.SOLOMON:
				$VBoxContainer/PlayerNum.text = "Players Required: 2"
	
	resizeSelf()

func onMatchTypeSelected(index):
	Settings.matchType = index
	if index == Settings.MATCH_TYPE.TOURNAMENT:
		$VBoxContainer/GPMHbox.visible = true
	else:
		$VBoxContainer/GPMHbox.visible = false
	resizeSelf()

func onBackPressed():
	emit_signal("close")
	hide()

func onPrivateButtonPressed():
	$VBoxContainer/HBoxContainer/PrivateButton.disabled = true
	$VBoxContainer/HBoxContainer/PublicButton.disabled = false

func onPublicButtonPressed():
	$VBoxContainer/HBoxContainer/PrivateButton.disabled = false
	$VBoxContainer/HBoxContainer/PublicButton.disabled = true

func getGameParams() -> Dictionary:
	var params = {}
	params["is_public"] = $VBoxContainer/HBoxContainer/PublicButton.disabled
	params["version"] = Settings.versionID
	params["game_type"] = $VBoxContainer/GameTypeHbox/OptionButton.selected
	params["match_type"] = $VBoxContainer/MatchTypeHbox/OptionButton.selected
	
	if params["match_type"] == Settings.MATCH_TYPE.TOURNAMENT:
		params["games_per_match"] = $VBoxContainer/GPMHbox/LineEdit.get_value()
	
	if params["game_type"] == Settings.GAME_TYPES.DRAFT:
		params["draft_type"] = $VBoxContainer/DraftTypeHbox/OptionButton.selected
		params["num_boosters"] = $VBoxContainer/PacksHbox/LineEdit.get_value()
	
	return params

func setOwnGameParams(params : Dictionary):
	$VBoxContainer/GameTypeHbox/OptionButton.select(params["game_type"])
	onGameTypeSelected(params["game_type"])
	$VBoxContainer/MatchTypeHbox/OptionButton.select(params["match_type"])
	onMatchTypeSelected(params["match_type"])
	
	if params["match_type"] == Settings.MATCH_TYPE.TOURNAMENT:
		$VBoxContainer/GPMHbox/LineEdit.text = str(params["games_per_match"])
		Tournament.gamesPerMatch = params["games_per_match"]
	
	if params["game_type"] == Settings.GAME_TYPES.DRAFT:
		$VBoxContainer/DraftTypeHbox/OptionButton.select(params["draft_type"])
		onDraftTypeSelected(params["draft_type"])
		$VBoxContainer/PacksHbox/LineEdit.text = str(params["num_boosters"])
		
		Settings.selectedDeck = ".draft.json"

func onTurnTimerSelected(index : int):
	Settings.turnTimerMax = Settings.TURN_TIMES.values()[index]

func onGameTimerSelected(index : int):
	Settings.gameTimerMax = Settings.GAME_TIMES.values()[index]
