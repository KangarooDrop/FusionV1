extends Node2D

class_name PopupUI

var margin = 8

var options := []

func GET_CLOSE_BUTTON() -> Array:
	return ["Close", null, null, []]

func init(notice : String = "Notice", text : String = "", buttonData : Array = [GET_CLOSE_BUTTON()]) -> Node:
	$VBoxContainer/Notice.text = notice
	$VBoxContainer/Text.text = text
	setButtons(buttonData)
	
	return self

func setButtons(buttonData : Array = [GET_CLOSE_BUTTON()]):
	for c in $VBoxContainer/ButtonHolder.get_children():
		c.queue_free()
		$VBoxContainer/ButtonHolder.remove_child(c)
	
	for i in range(buttonData.size()):
		var btn = buttonData[i]
		var button = Button.new()
		button.name = "Option_" + str(i)
		NodeLoc.setButtonParams(button)
		button.text = btn[0]
		if btn[1] != null:
			button.connect("button_down", btn[1], btn[2], btn[3])
		if btn.size() < 5 or btn[4]:
			button.connect("button_down", self, "onButtonPressed")
		$VBoxContainer/ButtonHolder.add_child(button)
		
		options.append(button)
	
	for i in range(options.size()):
		options[i].focus_neighbour_bottom = "../" + options[i].name
		if i == 0:
			options[i].focus_neighbour_left = "../" + options[i].name
		else:
			options[i].focus_neighbour_left =  "../" + options[i-1].name
		if i == options.size() - 1:
			options[i].focus_neighbour_right = "../" + options[i].name
		else:
			options[i].focus_neighbour_right =  "../" + options[i+1].name
		options[i].focus_neighbour_top = "../" + options[i].name
	
	if options.size() > 0:
		options[0].grab_focus()
	
	call_deferred("setBackgroundSize")


func setBackgroundSize():
	$Background.rect_size = $VBoxContainer.rect_size + Vector2(margin * 2, margin * 2)
	$Background.rect_position = $VBoxContainer.rect_position - Vector2(margin, margin)

func close():
	queue_free()

func onButtonPressed():
	close()
