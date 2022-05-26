extends Node

var player_name = null

"""
	[Request Form]: Username/Email - Submit button
	[Password Reset Form]: Code, pass, confirm pass
	[Confirmation/Rejection]: Yoop
"""

func _ready():
	SilentWolf.Auth.connect("sw_request_password_reset_succeeded", self, "_on_send_code_succeeded")
	SilentWolf.Auth.connect("sw_request_password_reset_failed", self, "_on_send_code_failed")
	
	SilentWolf.Auth.connect("sw_reset_password_succeeded", self, "_on_reset_succeeded")
	SilentWolf.Auth.connect("sw_reset_password_failed", self, "_on_reset_failed")
	
	$RequestWindow/VBoxContainer/UsernameLineEdit.grab_focus()








func _on_RequestSubmitButton_pressed():
	player_name = $RequestWindow/VBoxContainer/UsernameLineEdit.text
	SilentWolf.Auth.request_player_password_reset(player_name)
	$LoadingWindow.get_node("Label").text = "Connecting to Server"
	$LoadingWindow.show()

func _on_send_code_succeeded():
	$LoadingWindow.hide()
	$FormWindow.show()
	$RequestWindow.hide()
	$FormWindow/VBoxContainer/VBoxContainer/CodeLineEdit.grab_focus()

func _on_send_code_failed(error):
	$LoadingWindow.hide()
	createPopup("Error", "Could not send confirmation code. " + str(error))

func _on_RequestBackButton_pressed():
	get_tree().change_scene("res://Scenes/Login/Login.tscn")

func on_Request_LineEdit_Enter(new_text):
	_on_RequestSubmitButton_pressed()









func _on_FormSubmitButton_pressed():
	var code = $FormWindow/VBoxContainer/VBoxContainer/CodeLineEdit.text
	var password = $FormWindow/VBoxContainer/VBoxContainer/PasswordLineEdit.text
	var confirm_password = $FormWindow/VBoxContainer/VBoxContainer/PasswordLineEdit2.text
	SilentWolf.Auth.reset_player_password(player_name, code, password, confirm_password)
	$LoadingWindow.get_node("Label").text = "Connecting to Server"
	$LoadingWindow.show()

func _on_reset_succeeded():
	$LoadingWindow.hide()
	$FormWindow.hide()
	createPopup("Success", "Your password was successfully reset", [["Close", self, "on_success_change_close", []]])

func on_success_change_close():
	get_tree().change_scene("res://Scenes/Login/Login.tscn")

func _on_reset_failed(error):
	$LoadingWindow.hide()
	createPopup("Error", "Could not reset password. " + str(error))

func _on_FormBackButton_pressed():
	$FormWindow/VBoxContainer/VBoxContainer/UsernameLineEdit.text  = ""
	$FormWindow/VBoxContainer/VBoxContainer/PasswordLineEdit.text  = ""
	$FormWindow/VBoxContainer/VBoxContainer/PasswordLineEdit2.text = ""
	$FormWindow.hide()
	$RequestWindow.show()

func on_Form_LineEdit_Enter(new_text):
	_on_FormSubmitButton_pressed()









func createPopup(title : String, desc : String, options = null):
	var pop = MessageManager.createPopup(title, desc, [])
	if options == null:
		options = pop.GET_CLOSE_BUTTON()
	pop.setButtons(options)
