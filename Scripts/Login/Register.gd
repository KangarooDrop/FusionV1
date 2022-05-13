extends Node

var popupUI = preload("res://Scenes/UI/PopupUI.tscn")

func _ready():
	SilentWolf.Auth.connect("sw_registration_succeeded", self, "_on_registration_succeeded")
	SilentWolf.Auth.connect("sw_registration_failed", self, "_on_registration_failed")
	
func _on_SubmitButton_pressed():
	var player_name = 		$SignUpWindow/VBoxContainer/UsernameLineEdit.text
	var email = 			$SignUpWindow/VBoxContainer/EmailLineEdit.text
	var password = 			$SignUpWindow/VBoxContainer/PasswordLineEdit.text
	var confirm_password = 	$SignUpWindow/VBoxContainer/PasswordLineEdit2.text
	
	SilentWolf.Auth.register_player(player_name, email, password, confirm_password)
	$LoadingWindow.get_node("Label").text = "Connecting to Server"
	$LoadingWindow.show()
	
func _on_registration_succeeded():
	get_tree().change_scene("res://Scenes/Login/ConfirmEmail.tscn")
	
func _on_registration_failed(error):
	$LoadingWindow.hide()
	createPopup("Error", str(error))

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
