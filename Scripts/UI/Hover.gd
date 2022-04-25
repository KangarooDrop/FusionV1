extends Node2D

var text := ""

var maxTextLen = 225
var flipped = false

var parentWindow = null
var spawnedWindows = []

var closeOnMouseExit = false
var closeChildrenFirst = false

var yieldTimer = 0

func _ready():
	$Label.connect("meta_clicked", self, "handle")
		

var textA = "\n[color=aqua][url=AbilityFrostbite]Frostbite[/url][/color]"

func setText(text : String, margin = 4):
	self.text = text
	$Label.bbcode_text = text
	
	$Label.rect_position.x = margin
	
	$Label.rect_size.x = maxTextLen
	
	$Label.rect_position.y = -$Label.get_minimum_size().y / 2
	$HoverBack.rect_size = Vector2(maxTextLen + margin * 2, $Label.get_minimum_size().y + margin * 2)
	$HoverBack.rect_position.y = -$HoverBack.rect_size.y / 2
	
	if flipped:
		scale.x = -1
		$Label.rect_scale.x = -1
		$Label.rect_position.x += $Label.rect_size.x
	
	yieldTimer = 0

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
	var card = null
	if spl.size() >= 3:
		card = ListOfCards.getCard(int(spl[2]))
	
	var abl = null
	for data in ProjectSettings.get_setting("_global_script_classes"):
		if data["class"] == fileName:
			abl = load(data["path"])
			break
	if abl != null:
		var ability = abl.new(card).setCount(count)
		
		closeChildrenFirst = true
		
		var hoverInst = load("res://Scenes/UI/Hover.tscn").instance()
		hoverInst.z_index = z_index + 1
		get_parent().add_child(hoverInst)
		hoverInst.flipped = flipped
		hoverInst.setText(ability.genDescription())
		hoverInst.global_position = get_global_mouse_position() + Vector2(3, 0) * (1 if flipped else -1)# * Vector2(0, hoverInst.get_node("HoverBack").rect_size.y / 2)
		
		spawnedWindows.append(hoverInst)
		hoverInst.parentWindow = self
	
func close(closeAll = false) -> bool:
	if closeChildrenFirst and not closeAll:
		if spawnedWindows.size() == 0:
			queue_free()
			if is_instance_valid(parentWindow):
				parentWindow.spawnedWindows.erase(self)
			return true
		else:
			spawnedWindows[0].close()
			return false
	
	else:
		queue_free()
		var windows = spawnedWindows.duplicate()
		for w in windows:
			w.close(closeAll)
		if is_instance_valid(parentWindow):
			parentWindow.spawnedWindows.erase(self)
			
		return true
		
func _physics_process(delta):
	for c in spawnedWindows:
		c.scale = scale
	if closeOnMouseExit and not isMouseOn(true):
		close()
	if yieldTimer == 0:
		yieldTimer = 1
		$Label.rect_size.y = 0

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
