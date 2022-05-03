extends Node

var fontTRES = preload("res://Fonts/FontNormal.tres")
var bHover = preload("res://Art/UI/ButtonStyles/ButtonHover.tres")
var bNormal = preload("res://Art/UI/ButtonStyles/ButtonNormal.tres")
var bPressed = preload("res://Art/UI/ButtonStyles/ButtonPressed.tres")

func getBoard() -> Node:
	var b = null
	
	b = get_node_or_null("/root/main/CenterControl/Board")
	if b != null:
		return b
	
	b = get_node_or_null("/root/DeckEditor")
	if b != null:
		return b
	
	b = get_node_or_null("/root/Draft")
	if b != null:
		return b
	
	b = get_node_or_null("/root/DraftLobby")
	if b != null:
		return b
	
	b = get_node_or_null("/root/TournamentLobby")
	if b != null:
		return b
	
	return null

func setButtonParams(button : Button):
	button.set("custom_colors/font_color", Color(0, 0, 0))
	button.set("custom_colors/font_color_disabled", Color(0, 0, 0))
	button.set("custom_colors/font_color_hover", Color(0, 0, 0))
	button.set("custom_colors/font_color_pressed", Color(0, 0, 0))
	button.set("custom_fonts/font", fontTRES)
	button.set("custom_styles/hover", bHover)
	button.set("custom_styles/pressed", bPressed)
	button.set("custom_styles/normal", bNormal)
	
func setLineEditParams(lineEdit : LineEdit):
	lineEdit.set("custom_colors/font_color", Color(0, 0, 0))
#	lineEdit.set("custom_colors/selection_color", Color(0, 0, 0))
	lineEdit.set("custom_colors/cursor_color", Color(0, 0, 0))
#	lineEdit.set("custom_colors/clear_button_color_pressed", Color(0, 0, 0))
#	lineEdit.set("custom_colors/font_color_selected", Color(0, 0, 0))
#	lineEdit.set("custom_colors/clear_button_color", Color(0, 0, 0))
#	lineEdit.set("custom_colors/font_color_uneditable", Color(0, 0, 0))
	lineEdit.set("custom_fonts/font", fontTRES)
	lineEdit.set("custom_styles/hover", bHover)
	lineEdit.set("custom_styles/pressed", bPressed)
	lineEdit.set("custom_styles/normal", bNormal)
	
func setLabelParams(label : Label, inBox = false):
	label.set("custom_colors/font_color", Color(0, 0, 0))
	label.set("custom_fonts/font", fontTRES)
	if inBox:
		label.set("custom_styles/normal", bHover)
	
