extends Node2D

class_name OptionDisplay

signal onBackPressed()
signal onOptionPressed(button, key)

var optionList : Array = []

var maxSize : Vector2 = Vector2(400, 300)

func loadFiles(title : String, path : String, extensions := ["txt"]):
	var options = []
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			for ex in extensions:
				if file.ends_with(ex):
					options.append(file.get_basename())
					files.append(file)
	dir.list_dir_end()
	
	setOptions(title, options, files)


func setOptions(title : String, options := [], keys := []):
	if keys.size() < options.size():
		for i in range(options.size() - keys.size()):
			keys.append(null)
	show()
	$VBoxContainer/Label.text = title
	
	for c in $VBoxContainer/ScrollContainer/ButtonHolder.get_children():
		if c is Button and c.name != "BackButton":
			$VBoxContainer/ScrollContainer/ButtonHolder.remove_child(c)
			c.queue_free()
	optionList.clear()
	for i in range(options.size()):
		var b = Button.new()
		$VBoxContainer/ScrollContainer/ButtonHolder.add_child(b)
		b.text = str(options[i])
		b.rect_min_size.x = 200
		NodeLoc.setButtonParams(b)
		b.connect("pressed", self, "onOptionButtonPressed", [b, keys[i]])
		$VBoxContainer/ScrollContainer/ButtonHolder.move_child(b, i+1)
		optionList.append(str(options[i]))
	$VBoxContainer/ScrollContainer/ButtonHolder.set_anchors_and_margins_preset(Control.PRESET_CENTER)
	
	var chs = $VBoxContainer/ScrollContainer/ButtonHolder.get_children()
	for c in chs.duplicate():
		if not c is Button:
			chs.erase(c)
	for i in range(chs.size()):
		chs[i].focus_neighbour_left = "../" + chs[i].name
		chs[i].focus_neighbour_right = "../" + chs[i].name
		if i == 0:
			chs[i].focus_neighbour_top = "../" + chs[i].name
		else:
			chs[i].focus_neighbour_top = "../" + chs[i-1].name
		if i == chs.size() - 1:
			chs[i].focus_neighbour_bottom = "../" + chs[i].name
		else:
			chs[i].focus_neighbour_bottom = "../" + chs[i+1].name
	
	if chs.size() > 0:
		chs[0].grab_focus()
	else:
		$VBoxContainer/BackButton.grab_focus()
	
	#var hasScroll = $VBoxContainer/ScrollContainer/ButtonHolder.rect_size.y > maxSize.y
	
	yield(get_tree(), "idle_frame")
	
	var size = $VBoxContainer/ScrollContainer/ButtonHolder.rect_size
	$VBoxContainer/ScrollContainer.rect_min_size.x = min(maxSize.x, size.x)
	$VBoxContainer/ScrollContainer.rect_min_size.y = min(maxSize.y, size.y)
	$VBoxContainer/ScrollContainer.rect_size = Vector2()
	$VBoxContainer.rect_size = Vector2()
	$VBoxContainer.rect_position = -$VBoxContainer/ScrollContainer.rect_min_size / 2
	
	yield(get_tree(), "idle_frame")
	
	var backBuffer = Vector2(60, 60)
	$Background.rect_size = $VBoxContainer.rect_size + backBuffer
	$Background.rect_position = $VBoxContainer.rect_position - backBuffer / 2
	
#	$VBoxContainer.rect_position = -$Background.rect_size / 2 + backBuffer - Vector2(0, 10)
	#$Background.rect_position = $VBoxContainer.rect_position - Vector2(30, 10)

func hideBack() -> Node:
	$VBoxContainer/BackButton.visible = false
	return self

func onBackPressed():
	emit_signal("onBackPressed")


func onOptionButtonPressed(button : Button, key):
	emit_signal("onOptionPressed", button, key)
