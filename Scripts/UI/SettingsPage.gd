extends Control

func _ready():
	$Anims/CheckBox.pressed = Settings.playAnimations
	$NumSpectators/LineEdit.text = str(Server.MAX_PEERS - 1)
	$NumSpectators/LineEdit.oldtext = $NumSpectators/LineEdit.text

func onBackPressed():
	visible = false
	get_parent().get_node("VBoxContainer").visible = true
	setNumSpectators($NumSpectators/LineEdit.get_value())
	Settings.writeToSettings()
	
func setNumSpectators(num : int):
	Server.MAX_PEERS = num + 1

func setPlayAnims(button_pressed : bool):
	Settings.playAnimations = button_pressed
