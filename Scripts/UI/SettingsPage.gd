extends Control

func _ready():
	$Anims/CheckBox.pressed = Settings.playAnimations
	$NumDraft/LineEdit.text = str(Server.MAX_PEERS + 1)
	$NumDraft/LineEdit.oldtext = $NumDraft/LineEdit.text
	$Username/LineEdit.text = Server.username

func onBackPressed():
	visible = false
	get_parent().get_node("VBoxContainer").visible = true
	setNumDraft($NumDraft/LineEdit.get_value())
	setUsername(get_node("Username/LineEdit").text)
	Settings.writeToSettings()

func setPlayAnims(button_pressed : bool):
	Settings.playAnimations = button_pressed

func setNumDraft(num : int):
	Server.MAX_PEERS = num - 1
	
func setUsername(username : String):
	Server.username = username
