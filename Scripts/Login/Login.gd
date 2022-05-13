extends Node

var popupUI = preload("res://Scenes/UI/PopupUI.tscn")

func _ready():
	SilentWolf.Auth.connect("sw_login_succeeded", self, "_on_login_succeeded")
	SilentWolf.Auth.connect("sw_login_failed", self, "_on_login_failed")
	
	$SignUpWindow/VBoxContainer/VBoxContainer/UsernameLineEdit.grab_focus()

func _on_SubmitButton_pressed():
	var username = $SignUpWindow/VBoxContainer/VBoxContainer/UsernameLineEdit.text
	var password = $SignUpWindow/VBoxContainer/VBoxContainer/PasswordLineEdit.text
	var remember_me = $SignUpWindow/VBoxContainer/HBoxContainer2/CheckBox.is_pressed()
	SilentWolf.Auth.login_player(username, password, remember_me)
	
	$LoadingWindow.get_node("Label").text = "Connecting to Server"
	$LoadingWindow.show()
	
func _on_login_succeeded():
	get_tree().change_scene("res://Scenes/StartupScreen.tscn")
	
func _on_login_failed(error):
	$LoadingWindow.hide()
	
	if "UserNotConfirmedException" in error:
		var confirm = load("res://Scenes/Login/ConfirmEmail.tscn").instance()
		
		var root = get_node("/root")
		root.add_child(confirm)
		get_tree().current_scene = confirm
		
		confirm._on_ResendButton_pressed()
		confirm.backPath = "res://Scenes/Login/Login.tscn"
		
		root.remove_child(self)
		self.queue_free()
	else:
		createPopup("Error Loggin In", str(error))

func _on_RichTextLabel_meta_clicked(meta):
	get_tree().change_scene("res://Scenes/Login/ResetPassword.tscn")

func _on_BackButton_pressed():
	get_tree().change_scene("res://Scenes/Login/Home.tscn")

func createPopup(title : String, desc : String, options = null):
	var pop = popupUI.instance()
	if options == null:
		options = [["Close", pop, "close", []]]
	pop.init(title, desc, options)
	$PopupHolder.add_child(pop)
	pop.options[0].grab_focus()

func on_LineEdit_Enter(new_text):
	_on_SubmitButton_pressed()
