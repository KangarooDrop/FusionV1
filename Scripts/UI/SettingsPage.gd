extends Control

var fontTRES = preload("res://Fonts/FontNormal.tres")

signal settingsClose

func _ready():
	$Anims/CheckBox.pressed = Settings.playAnimations
	$NumDraft/LineEdit.text = str(Server.MAX_PEERS + 1)
	$NumDraft/LineEdit.oldtext = $NumDraft/LineEdit.text
	$Username/LineEdit.text = Server.username

func onBackPressed():
	emit_signal("settingsClose")
	
	visible = false
	setNumDraft($NumDraft/LineEdit.get_value())
	setUsername(get_node("Username/LineEdit").text)
	Settings.writeToSettings()

func setPlayAnims(button_pressed : bool):
	Settings.playAnimations = button_pressed

func setNumDraft(num : int):
	Server.MAX_PEERS = num - 1
	
func setUsername(username : String):
	Server.username = username

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
	for i in range(files.size()):
		if not files[i].begins_with(".") and files[i].ends_with("shader"):
			var b = Button.new()
			$FileDisplay/ButtonHolder.add_child(b)
			b.text = files[i].get_basename().capitalize()
			b.set("custom_fonts/font", fontTRES)
			b.connect("pressed", self, "onShaderLoadButtonPressed", [files[i]])
			$FileDisplay/ButtonHolder.move_child(b, i+1)
	yield(get_tree(), "idle_frame")
	$FileDisplay/ButtonHolder.set_anchors_and_margins_preset(Control.PRESET_CENTER)
	$FileDisplay/ButtonHolder.rect_position.y -= 64
	$FileDisplay/Background.rect_size = $FileDisplay/ButtonHolder.rect_size + Vector2(60, 20)
	$FileDisplay/Background.rect_position = $FileDisplay/ButtonHolder.rect_position - Vector2(30, 10)

func onShaderLoadButtonPressed(path):
	$Shaders/SelectShaderButton.text = path.get_basename().capitalize()
	ShaderHandler.setShader(Settings.shaderPath + path)
	onShaderBackButtonPressed()

func onShaderBackButtonPressed():
	$FileDisplay.visible = false
