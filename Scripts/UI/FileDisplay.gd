extends Node2D

signal onBackPressed()
signal onFilePressed(fileName)

var fileList : Array = []

var maxSize : Vector2 = Vector2(400, 300)

func loadFiles(title : String, path : String, extensions := ["txt"]):
	show()
	$ScrollContainer/ButtonHolder/Label.text = title
	
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
					files.append(file)
	dir.list_dir_end()
	
	for c in $ScrollContainer/ButtonHolder.get_children():
		if c is Button and c.name != "BackButton":
			$ScrollContainer/ButtonHolder.remove_child(c)
			c.queue_free()
	fileList.clear()
	for i in range(files.size()):
		var b = Button.new()
		$ScrollContainer/ButtonHolder.add_child(b)
		b.text = str(files[i].get_basename())
		NodeLoc.setButtonParams(b)
		b.connect("pressed", self, "onFileLoadButtonPressed", [files[i]])
		$ScrollContainer/ButtonHolder.move_child(b, i+1)
		fileList.append(files[i])
	$ScrollContainer/ButtonHolder.set_anchors_and_margins_preset(Control.PRESET_CENTER)
	
	var chs = $ScrollContainer/ButtonHolder.get_children()
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
		
	chs[0].grab_focus()
	
	var hasScroll = $ScrollContainer/ButtonHolder.rect_size.y > maxSize.y
	
	yield(get_tree(), "idle_frame")
	
	var size = $ScrollContainer/ButtonHolder.rect_size
	
	$ScrollContainer.rect_min_size.x = min(maxSize.x, size.x)
	if hasScroll:
		$ScrollContainer.rect_min_size.x += 32
	$ScrollContainer.rect_min_size.y = min(maxSize.y, size.y)
	$ScrollContainer.rect_size = Vector2()
	$ScrollContainer.rect_position = -$ScrollContainer.rect_min_size / 2
	
	$Background.rect_size = $ScrollContainer.rect_size + Vector2(60, 20)
	$Background.rect_position = $ScrollContainer.rect_position - Vector2(30, 10)
	
		
func onFileLoadBackPressed():
	emit_signal("onBackPressed")
	
func onFileLoadButtonPressed(fileName : String):
	emit_signal("onFilePressed", fileName)
