extends Control

signal settingsClose

func _ready():
	$VBox/Anims/CheckBox.pressed = Settings.playAnimations
	$VBox/Username/LineEdit.text = Server.username
	$VBox/SoundSlider/HSlider.value = SoundEffectManager.volume
	$VBox/MusicSlider/HSlider.value = MusicManager.volume
	
	ShaderHandler.connect("shaderChange", self, "onShaderChange")
	$FDCenter/FileDisplay.connect("onBackPressed", self, "onShaderBackButtonPressed")
	$FDCenter/FileDisplay.connect("onFilePressed", self, "onShaderLoadButtonPressed")

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
	$FDCenter/FileDisplay.loadFiles("Select Shader", Settings.shaderPath, ["shader"])

func onShaderLoadButtonPressed(path):
	ShaderHandler.setShader(Settings.shaderPath + path)
	onShaderBackButtonPressed()

func onShaderBackButtonPressed():
	$FDCenter/FileDisplay.hide()

func onShaderChange(path : String):
	$VBox/Shaders/SelectShaderButton.text = path.get_file().get_basename().capitalize()

func _exit_tree():
	ShaderHandler.disconnect("shaderChange", self, "onShaderChange")

func onSoundVolumeChange(value):
	SoundEffectManager.setVolume(value)

func onMusicVolumeChange(value):
	MusicManager.setVolume(value)
