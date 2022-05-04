extends Sprite

class_name CardOverlay

var source : Ability = null setget setSource
var destroyOnRemove : bool = false setget setDestroyOnRemove

func setTexture(tex : Texture) -> Sprite:
	texture = tex
	return self

func setSource(abl) -> Sprite:
	source = abl
	return self

func setDestroyOnRemove(dOR : bool) -> Sprite:
	destroyOnRemove = dOR
	return self
	
func _physics_process(delta):
	if destroyOnRemove:
		if source != null:
			if source.card == null or not is_instance_valid(source.card.cardNode) or source.card.cardNode != get_node("../../"):
				queue_free()

func remove():
	queue_free()
