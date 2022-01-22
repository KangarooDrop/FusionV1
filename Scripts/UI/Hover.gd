extends Node2D

var text := ""

var maxTextLen = 150
var flipped = false

var spawnedWindows = []

var closeOnMouseExit = false

func _ready():
	pass
		

var textA = "\n[color=aqua][url=AbilityFrostbite]Frostbite[/url][/color]"

func setText(text : String, margin = 4):
	
	self.text = text
	$Label.bbcode_text = text
	
	#$Label.bbcode_text += textA
	$Label.connect("meta_clicked", self, "handle")
	
	$Label.rect_position.x = margin
	$Label.rect_size.x = maxTextLen
	$Label.rect_position.y = -$Label.get_minimum_size().y / 2
	$HoverBack.rect_size = Vector2(maxTextLen + margin * 2, $Label.get_minimum_size().y + margin * 2)
	$HoverBack.rect_position.y = -$HoverBack.rect_size.y / 2
	
	if flipped:
		scale.x = -1
		$Label.rect_scale.x = -1
		$Label.rect_position.x += $Label.rect_size.x
		
	"""
	var label = Label.new()
	label.autowrap = true
	label.set("custom_colors/font_color", Color(1,0,0))
	add_child(label)
	label.rect_size = Vector2(maxTextLen, 100)
	
	for s in splitText("[c=$FF]|AbilitySacrifice|[/c]", "|"):
		if s[0] != "|":
			label.text += s
		else:
			s.erase(0, 1)
			
			var labelNew = Label.new()
			labelNew.text = s
			labelNew.autowrap = false
			labelNew.set("custom_colors/font_color", Color(0,1,0))
			add_child(labelNew)
			var textLen = label.get_font("font").get_string_size(label.text).x
			labelNew.rect_position.x = int(textLen) % maxTextLen
			label.text += "  ".repeat(s.length())
			
			if flipped:
				labelNew.rect_position.x = maxTextLen - labelNew.rect_position.x
				labelNew.rect_scale.x = -1
			
		label.rect_position.x = maxTextLen
			
		if flipped:
			label.rect_scale.x = -1
	"""

static func splitText(string, delimiter):
	var out = []
	var open = false
	var text = ""
	for t in string:
		if t == delimiter:
			out.append(text)
			text = ""
			if open:
				open = false
			else:
				open = true
				text += delimiter
		else:
			text += t
	if text.length() > 0:
		out.append(text)
	return out

func handle(meta):
	var abl = null
	for data in ProjectSettings.get_setting("_global_script_classes"):
		if data["class"] == meta:
			abl = load(data["path"])
			break
	if abl != null:
		var ability = abl.new(null)
		
		var hoverInst = load("res://Scenes/UI/Hover.tscn").instance()
		hoverInst.closeOnMouseExit = true
		hoverInst.z_index = z_index + 1
		get_parent().add_child(hoverInst)
		hoverInst.flipped = flipped
		hoverInst.setText(ability.desc)
		hoverInst.global_position = get_global_mouse_position() + Vector2(3, 0) * (1 if flipped else -1)# * Vector2(0, hoverInst.get_node("HoverBack").rect_size.y / 2)
		
		spawnedWindows.append(hoverInst)
	
func close():
	#fadingOut = true
	queue_free()
	var windows = spawnedWindows.duplicate()
	for w in windows:
		if is_instance_valid(w):
			w.close()
			spawnedWindows.erase(w)
	
func _physics_process(delta):
			
	if closeOnMouseExit and not isMouseOn(true):
		close()

func isMouseOn(recursive = false) -> bool:
	var mousePos = get_viewport().get_mouse_position() - get_viewport_rect().size / 2 
	var mp = get_local_mouse_position()
	if mp.x > 0 and mp.x < $HoverBack.rect_size.x:
		if mp.y > -$HoverBack.rect_size.y/2 and mp.y < $HoverBack.rect_size.y/2:
			return true
		
	if recursive:
		for w in spawnedWindows:
			if is_instance_valid(w):
				if w.isMouseOn(true):
					return true
	
	return false
