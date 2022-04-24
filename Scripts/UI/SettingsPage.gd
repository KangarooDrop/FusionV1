extends Control

signal settingsClose

func _ready():
	$VBox/Anims/CheckBox.pressed = Settings.playAnimations
	$VBox/Username/LineEdit.text = Server.username
	$VBox/SoundSlider/HSlider.value = SoundEffectManager.volume
	$VBox/MusicSlider/HSlider.value = MusicManager.volume
	
	ShaderHandler.connect("shaderChange", self, "onShaderChange")

func onBackPressed():
	emit_signal("settingsClose")
	
	visible = false
	setUsername($VBox/Username/LineEdit.text)
	Settings.writeToSettings()

func setPlayAnims(button_pressed : bool):
	Settings.playAnimations = button_pressed
	
func setUsername(username : String):
	Server.setPlayerName(username)

func openShaderFolder():
	OS.shell_open(ProjectSettings.globalize_path("user://") + "shaders/")
	#OS.shell_open(OS.get_user_data_dir() + "/shaders")

func shaderButtonPressed():
	
	$FileDisplay.visible = true
	$FileDisplay/ButtonHolder/Label.text = "Load File"
	
	var files = FileIO.getAllFiles(Settings.shaderPath)
	
	for c in $FileDisplay/ButtonHolder.get_children():
		if c is Button and c.name != "BackButton":
			$FileDisplay/ButtonHolder.remove_child(c)
			c.queue_free()
	var c = 0
	for i in range(files.size()):
		if not files[i].begins_with(".") and files[i].ends_with("shader"):
			var b = Button.new()
			$FileDisplay/ButtonHolder.add_child(b)
			b.text = files[i].get_basename().capitalize()
			NodeLoc.setButtonParams(b)
			b.connect("pressed", self, "onShaderLoadButtonPressed", [files[i]])
			c += 1
			$FileDisplay/ButtonHolder.move_child(b, c)
	yield(get_tree(), "idle_frame")
	$FileDisplay/ButtonHolder.set_anchors_and_margins_preset(Control.PRESET_CENTER)
	#$FileDisplay/ButtonHolder.rect_position.y -= 64
	$FileDisplay/Background.rect_size = $FileDisplay/ButtonHolder.rect_size + Vector2(60, 20)
	$FileDisplay/Background.rect_position = $FileDisplay/ButtonHolder.rect_position - Vector2(30, 10)

func onShaderChange(path : String):
	$VBox/Shaders/SelectShaderButton.text = path.get_file().get_basename().capitalize()

func _exit_tree():
	ShaderHandler.disconnect("shaderChange", self, "onShaderChange")

func onShaderLoadButtonPressed(path):
	ShaderHandler.setShader(Settings.shaderPath + path)
	onShaderBackButtonPressed()

func onShaderBackButtonPressed():
	$FileDisplay.visible = false

func onSoundVolumeChange(value):
	SoundEffectManager.setVolume(value)

func onMusicVolumeChange(value):
	MusicManager.setVolume(value)
