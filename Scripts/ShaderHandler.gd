extends Node

var fontTRES = preload("res://Fonts/FontNormal.tres")
var fading = preload("res://Scenes/UI/FadingNode.tscn")

var shad = preload("res://Scenes/Shader.tscn")
var shadObj

var verifiedShaderData : Array = \
[
	["default", getDefaultCode()],
	["invert", getInvertCode()],
	["muttled", getMuttledCode()]
]

func getDefaultCode():
	return """shader_type canvas_item;
render_mode unshaded;

void fragment()
{
	COLOR.rgba = vec4(0, 0, 0, 0);
}
"""

func getInvertCode():
	return """shader_type canvas_item;
render_mode unshaded;

void fragment()
{
	vec4 c = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgba;
	c.r = 1.0 - c.r;
	c.g = 1.0 - c.g;
	c.b = 1.0 - c.b;
	COLOR.rgba = c;
}
"""

func getMuttledCode():
	return """shader_type canvas_item;
render_mode unshaded;

uniform float mullAmt = 0.5;

void fragment()
{
	COLOR.rgba = vec4(mullAmt, mullAmt, mullAmt, mullAmt);
}
"""

func _ready():
	verifyShaders()
	
	var centerControl = Control.new()
	centerControl.set_anchors_and_margins_preset(Control.PRESET_CENTER)
	add_child(centerControl)
	
	var node = Node2D.new()
	node.z_index = 4096
	centerControl.add_child(node)
	
	shadObj = shad.instance()
	node.add_child(shadObj)
	
	var canvas = CanvasLayer.new()
	canvas.name = "Canvas"
	add_child(canvas)
	
	var control = Control.new()
	control.name = "WarningHolder"
	canvas.add_child(control)
	control.set_anchors_and_margins_preset(Control.PRESET_TOP_RIGHT)

func verifyShaders():
	
	for data in verifiedShaderData:
		var fileName = data[0]
		
		var file = File.new()
		
		print(Settings.shaderPath + fileName + ".shader")
		if not file.file_exists(Settings.shaderPath + fileName + ".shader"):
			var directory = Directory.new( )
			directory.make_dir_recursive(Settings.shaderPath)
			
			var error = file.open(Settings.shaderPath + fileName + ".shader", File.WRITE)
			file.store_string(data[1])
			
		file.close()

var currentShader = "default.json"
func setShader(path : String, writeToSettings : bool = true):
	if path != Settings.shaderPath + "default.shader":
		makeWarning()
	
	currentShader = path
	var shader = load(path)
	shadObj.material.shader = shader
	if writeToSettings:
		Settings.writeToSettings()
	

func _input(event):
	if event is InputEventKey and event.is_pressed() and not event.is_echo() and event.scancode == KEY_F2:
		ShaderHandler.setShader(Settings.shaderPath + verifiedShaderData[0][0] + ".shader")

var warning = null
func makeWarning():
	if is_instance_valid(warning):
		pass
	else:
		warning = Label.new()
		warning.text = "Shader selected. Press F2 to use default shader"
		warning.set("custom_colors/font_color", Color(0,0,0))
		warning.set("custom_fonts/font", fontTRES.duplicate())
		warning.get("custom_fonts/font").outline_size = 1
		warning.grow_horizontal = Control.GROW_DIRECTION_BEGIN
		get_node("Canvas/WarningHolder").add_child(warning)
		warning.rect_position += Vector2(-16, 16)
		
		var fadingNode = fading.instance()
		fadingNode.fadeIn()
		fadingNode.freeOnFadeOut = true
		fadingNode.maxTime = 1
		fadingNode.connect("onFadeIn", self, "onFadeIn", [fadingNode])
		warning.add_child(fadingNode)

func onFadeIn(fadingNode : Node):
	yield(get_tree().create_timer(3), "timeout")
	fadingNode.fadeOut()
