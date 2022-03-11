extends Node2D

class_name PopupUI

var fontTRES = preload("res://Fonts/FontNormal.tres")

var margin = 8

func GET_CLOSE_BUTTON() -> Array:
	return ["Close", self, "close", []]
	

func  init(notice : String = "Notice", text : String = "", buttonData : Array = [GET_CLOSE_BUTTON()]):
	
	$VBoxContainer/Notice.text = notice
	$VBoxContainer/Text.text = text
	
	for btn in buttonData:
		var button = Button.new()
		button.set("custom_fonts/font", fontTRES)
		button.text = btn[0]
		button.connect("button_down", btn[1], btn[2], btn[3])
		$VBoxContainer/ButtonHolder.add_child(button)
		
	call_deferred("setBackgroundSize")

func setBackgroundSize():
	$Background.rect_size = $VBoxContainer.rect_size + Vector2(margin * 2, margin * 2)
	$Background.rect_position = $VBoxContainer.rect_position - Vector2(margin, margin)


func close():
	queue_free()
