extends Control

signal settingsClose

func _ready():
	#Waits until parent node has called its ready function
	yield(owner, "ready")
	
	$VBox/Username/LineEdit.text = Server.username
	$VBox/SoundSlider/HSlider.value = SoundEffectManager.volume
	$VBox/MusicSlider/HSlider.value = MusicManager.volume
	
	ShaderHandler.connect("shaderChange", self, "onShaderChange")
	$FDCenter/OptionDisplay.connect("onBackPressed", self, "onShaderBackButtonPressed")
	$FDCenter/OptionDisplay.connect("onOptionPressed", self, "onShaderLoadButtonPressed")
	

	var animOptions = []
	var animKeys = []
	for sp in Settings.ANIMATION_SPEEDS:
		animOptions.append(sp.capitalize())
		animKeys.append(Settings.ANIMATION_SPEEDS[sp] / 10.0)
	
	var index = Settings.ANIMATION_SPEEDS.values().find(int(Settings.animationSpeed * 10))
	var selector = $VBox/AnimSpeed/OptionSelector
	selector.holder = $OptionHolder
	selector.title = "Animation Speed"
	selector.options = animOptions
	selector.keys = animKeys
	selector.initOptions()
	selector.connect("onSelected", self, "onAnimSpeedSelected")
	selector.onIndexPressed(index)
	
	if Settings.gameMode == Settings.GAME_MODE.NONE:
		for t in Settings.TURN_TIMES.values():
			var string = ""
			if t == -1:
				string = "No limit"
			else:
				string = TurnTimer.intToTime(t)
			$VBox/TurnTimer/OptionButton.add_item(string)
		$VBox/TurnTimer/OptionButton.select(Settings.TURN_TIMES.values().find(Settings.turnTimerMax))
		
		for t in Settings.GAME_TIMES.values():
			var string = ""
			if t == -1:
				string = "No limit"
			else:
				string = TurnTimer.intToTime(t)
			$VBox/GameTimer/OptionButton.add_item(string)
		$VBox/GameTimer/OptionButton.select(Settings.GAME_TIMES.values().find(Settings.gameTimerMax))
	else:
		$VBox/TurnTimer.hide()
		$VBox/GameTimer.hide()
		
		$VBox.rect_size = Vector2()
	
func show():
	.show()
	var buffer = Vector2(64, 64)
	$VBox.rect_size = Vector2()
	$VBox.rect_position = -$VBox.rect_size / 2
	
	$NinePatchRect.rect_min_size = $VBox.rect_size + buffer
	$NinePatchRect.rect_size = Vector2()
	$NinePatchRect.rect_position = $VBox.rect_position - buffer / 2
	print($VBox.rect_size)

func onBackPressed():
	emit_signal("settingsClose")
	
	visible = false
	setUsername($VBox/Username/LineEdit.text)
	Settings.writeToSettings()
	
func setUsername(username : String):
	Server.setPlayerName(username)

func openShaderFolder():
	OS.shell_open(ProjectSettings.globalize_path("user://") + "shaders/")
	#OS.shell_open(OS.get_user_data_dir() + "/shaders")

func shaderButtonPressed():
	$FDCenter/OptionDisplay.loadFiles("Select Shader", Settings.shaderPath, ["shader"])

func onShaderLoadButtonPressed(button : Button, key):
	var fileName = key
	ShaderHandler.setShader(Settings.shaderPath + fileName)
	onShaderBackButtonPressed()

func onShaderBackButtonPressed():
	$FDCenter/OptionDisplay.hide()

func onShaderChange(path : String):
	$VBox/Shaders/SelectShaderButton.text = path.get_file().get_basename().capitalize()

func onAnimSpeedSelected(button, key):
	Settings.animationSpeed = key

func onTurnTimerSelected(index : int):
	Settings.turnTimerMax = Settings.TURN_TIMES.values()[index]

func onGameTimerSelected(index : int):
	Settings.gameTimerMax = Settings.GAME_TIMES.values()[index]

func _exit_tree():
	ShaderHandler.disconnect("shaderChange", self, "onShaderChange")

func onSoundVolumeChange(value):
	SoundEffectManager.setVolume(value)

func onMusicVolumeChange(value):
	MusicManager.setVolume(value)
