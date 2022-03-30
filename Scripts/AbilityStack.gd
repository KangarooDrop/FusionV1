
class_name AbilityStack

var stack := []

var hoverScene = preload("res://Scenes/UI/Hover.tscn")
var abilityHovers := []

var offset = 28

func size() -> int:
	return stack.size()

func add(data):
	stack.insert(0, data)
	var stackSize = stack.size()
	var h = createHoverNode(Vector2(-475-225/2, -100) + stackSize * Vector2(0, offset), NodeLoc.getBoard(), data[0].genDescription(), false)
	h.position = Vector2(-475-225/2, -100) + stackSize * Vector2(0, offset) + Vector2(0, h.get_node("HoverBack").rect_size.y / 2)
	NodeLoc.getBoard().stackTimer = NodeLoc.getBoard().stackMaxTime

func erase(data):
	var index = -1
	for i in range(stack.size()):
		if stack[i] == data:
			remove(i)
			break

func remove(index : int):
	abilityHovers[index].close(true)
	abilityHovers.remove(index)
	stack.remove(index)

func getFront():
	if size() > 0:
		return stack[0]
	else:
		return null

func pop() -> Array:
	return stack.pop_front()
	
func createHoverNode(position : Vector2, parent : Node, text : String, flipped = false) -> Node:
	var hoverInst = hoverScene.instance()
	hoverInst.flipped = flipped
	parent.add_child(hoverInst)
	hoverInst.position = position
	hoverInst.setText(text)
	abilityHovers.insert(0, hoverInst)
	return hoverInst

func _to_string() -> String:
	return str(stack)
