extends Node

onready var illegal_reg : RegEx = RegEx.new()
const illegal_regex : String = "[:;|\\[\\]\\\\]"
onready var reg : RegEx = RegEx.new()
const pass_regex : String = "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$"

func _ready():
	reg.compile(pass_regex)
	SilentWolf.Auth.connect("sw_registration_succeeded", self, "_on_registration_succeeded")
	SilentWolf.Auth.connect("sw_registration_failed", self, "_on_registration_failed")
	
func _on_SubmitButton_pressed():
	var player_name = 		$SignUpWindow/VBoxContainer/UsernameLineEdit.text
	var email = 			$SignUpWindow/VBoxContainer/EmailLineEdit.text
	var password = 			$SignUpWindow/VBoxContainer/PasswordLineEdit.text
	var confirm_password = 	$SignUpWindow/VBoxContainer/PasswordLineEdit2.text
	
	reg.compile(pass_regex)
	illegal_reg.compile(illegal_regex)
	
	if password == confirm_password:
		if reg.search(password) == null:
			createPopup("Error", "Password must be at least 8 characters, contain one letter, and contain one number")
			return
		if illegal_reg.search(player_name) != null or illegal_reg.search(password) != null:
			createPopup("Error", 'Usernames and passwords may not contain the characters : ; | \\ [ or ]')
			return
	else:
		createPopup("Error", "The two passwords don't patch")
		return
			
	
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
	var pop = MessageManager.createPopup(title, desc, [])
	if options == null:
		options = pop.GET_CLOSE_BUTTON()
	pop.setButtons(options)

func on_LineEdit_Enter(new_text):
	_on_SubmitButton_pressed()
