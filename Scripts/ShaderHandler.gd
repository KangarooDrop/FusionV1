extends Node

enum SHADER {NONE, INVERT, MUTTLED, RAND}
var currentShader : int = SHADER.INVERT

var shad = preload("res://Scenes/Shader.tscn")
var shadObj

var default = preload("res://Shaders/Default.shader")
var invert = preload("res://Shaders/Invert.shader")
var muttled = preload("res://Shaders/Muttled.shader")
var rand = preload("res://Shaders/Rand.shader")

var invertShader

static func getShaderData() -> Array:
	var arr = []
	arr.append('Default')
	arr.append('Invert')
	arr.append('Muttled')
	#arr.append('Scuffed')
	return arr

func _ready():
	
	var centerControl = Control.new()
	centerControl.set_anchors_and_margins_preset(Control.PRESET_CENTER)
	add_child(centerControl)
	
	var node = Node2D.new()
	node.z_index = 4096
	centerControl.add_child(node)
	
	shadObj = shad.instance()
	node.add_child(shadObj)
	
	setShader(0)
	
func setShader(index : int):
	currentShader = index
	var shader = default
	match currentShader:
		SHADER.INVERT:
			shader = invert
		SHADER.MUTTLED:
			shader = muttled
		SHADER.RAND:
			shader = rand
		_:
			pass
	
	shadObj.material.shader = shader
