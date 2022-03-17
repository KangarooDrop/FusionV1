extends Node2D

var text := ""

var maxTextLen = 175
var flipped = false

var parentWindow = null
var spawnedWindows = []

var closeOnMouseExit = false
var closeChildrenFirst = false

func _ready():
	$Label.connect("meta_clicked", self, "handle")
		

var textA = "\n[color=aqua][url=AbilityFrostbite]Frostbite[/url][/color]"

func setText(text : String, margin = 4):
	self.text = text
	$Label.bbcode_text = text
	
	$Label.rect_position.x = margin
	
	var textLength = $Label.get_font("normal_font").get_string_size(text).x
	textLength = min(maxTextLen, textLength)
	
	$Label.rect_size.x = textLength
	
	$Label.rect_position.y = -$Label.get_minimum_size().y / 2
	$HoverBack.rect_size = Vector2(textLength + margin * 2, $Label.get_minimum_size().y + margin * 2)
	$HoverBack.rect_position.y = -$HoverBack.rect_size.y / 2
	
	if flipped:
		scale.x = -1
		$Label.rect_scale.x = -1
		$Label.rect_position.x += $Label.rect_size.x
	
	yield(get_tree().create_timer(0.02), "timeout")
	$Label.rect_size.y = 0

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

func handle(meta : String):
	var spl = meta.split("||")
	var fileName = spl[0]
	var count = int(spl[1])
	
	var abl = null
	for data in ProjectSettings.get_setting("_global_script_classes"):
		if data["class"] == fileName:
			abl = load(data["path"])
			break
	if abl != null:
		var ability = abl.new(null)
		for i in range(count - 1):
			ability.combine(abl.new(null))
		
		closeChildrenFirst = true
		
		var hoverInst = load("res://Scenes/UI/Hover.tscn").instance()
		hoverInst.z_index = z_index + 1
		get_parent().add_child(hoverInst)
		hoverInst.flipped = flipped
		hoverInst.setText(ability.desc)
		hoverInst.global_position = get_global_mouse_position() + Vector2(3, 0) * (1 if flipped else -1)# * Vector2(0, hoverInst.get_node("HoverBack").rect_size.y / 2)
		
		spawnedWindows.append(hoverInst)
		hoverInst.parentWindow = self
	
func close(closeAll = false) -> bool:
	if closeChildrenFirst and not closeAll:
		if spawnedWindows.size() == 0:
			queue_free()
			return true
		
		var toRemove := []
		for w in spawnedWindows:
			if w.close():
				toRemove.append(w)
		for w in toRemove.duplicate():
			spawnedWindows.erase(w)
		
		return false
	
	else:
		queue_free()
		var windows = spawnedWindows.duplicate()
		for w in windows:
			if is_instance_valid(w):
				w.close(closeAll)
				spawnedWindows.erase(w)
		if is_instance_valid(parentWindow):
			parentWindow.spawnedWindows.erase(self)
			
		return true
		
func _physics_process(delta):
	for c in spawnedWindows:
		c.scale = scale
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
