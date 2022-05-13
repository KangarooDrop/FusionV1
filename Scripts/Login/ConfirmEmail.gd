extends Node

var popupUI = preload("res://Scenes/UI/PopupUI.tscn")

var backPath = "res://Scenes/Login/Register.tscn"

func _ready():
	SilentWolf.Auth.connect("sw_email_verif_succeeded", self, "_on_confirmation_succeeded")
	SilentWolf.Auth.connect("sw_email_verif_failed", self, "_on_confirmation_failed")
	SilentWolf.Auth.connect("sw_resend_conf_code_succeeded", self, "_on_resend_code_succeeded")
	SilentWolf.Auth.connect("sw_resend_conf_code_failed", self, "_on_resend_code_failed")

func _on_confirmation_succeeded():
	# redirect to configured scene (user is logged in after registration)
	get_tree().change_scene("res://Scenes/StartupScreen.tscn")

func _on_confirmation_failed(error):
	$LoadingWindow.hide()
	createPopup("Error", "email verification failed: " + str(error))

func _on_resend_code_succeeded():
	createPopup("Resent", "Confirmation code was resent to your email address. Please check your inbox (and your spam).")
	$LoadingWindow.hide()

func _on_resend_code_failed():
	createPopup("Error", "Confirmation code could not be resent")
	$LoadingWindow.hide()





func _on_SubmitButton_pressed():
	var username = SilentWolf.Auth.tmp_username
	var code = $RequestWindow/VBoxContainer/CodeLineEdit.text
	SilentWolf.Auth.verify_email(username, code)
	$LoadingWindow.get_node("Label").text = "Connecting to Server"
	$LoadingWindow.show()



func _on_ResendButton_pressed():
	var username = SilentWolf.Auth.tmp_username
	SilentWolf.Auth.resend_conf_code(username)
	$LoadingWindow.get_node("Label").text = "Connecting to Server"
	$LoadingWindow.show()




func _on_BackButton_pressed():
	get_tree().change_scene(backPath)




func createPopup(title : String, desc : String, options = null):
	var pop = popupUI.instance()
	if options == null:
		options = [["Close", pop, "close", []]]
	pop.init(title, desc, options)
	$PopupHolder.add_child(pop)
	pop.options[0].grab_focus()

func on_LineEdit_Enter(new_text):
	_on_SubmitButton_pressed()
