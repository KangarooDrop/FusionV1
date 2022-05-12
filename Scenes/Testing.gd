extends Control

var point : Vector2 = Vector2()

var p_node
var m_nodes = []

var p_size = 40
var m_size = 10

func _ready():
	point = Vector2(500, 300)
	
	p_node = ColorRect.new()
	p_node.color = Color.red
	p_node.rect_size = Vector2(p_size, p_size)
	p_node.rect_position = point + -p_node.rect_size / 2
	add_child(p_node)

func _physics_process(delta):
	for c in m_nodes:
		c.queue_free()
	m_nodes.clear()
	
	var mousePoint = get_global_mouse_position()
	
	var pos = mousePoint
	var starting = sign((pos - point).x) == sign((pos - point).y)
#	for i in range(100):
	while (pos - point).length() > m_size:
		var diff = pos - point
		var para = diff.normalized()
		var perp = Vector2(para.y, -para.x)
		if starting:
			perp *= -1
		
		var a = 1 - 1/(abs(diff.y / 100) + 1)
		var vec = (para + perp * a).normalized()
		
		var line = ColorRect.new()
		line.color = Color.black
		line.margin_top = -3
		line.margin_bottom = 3
		line.margin_right = m_size * 1.2
		line.margin_left = 0
		line.rect_rotation = 180/PI * Vector2().angle_to_point(vec)
		m_nodes.append(line)
		add_child(line)
		line.rect_position = pos
		
		pos -= vec * m_size
