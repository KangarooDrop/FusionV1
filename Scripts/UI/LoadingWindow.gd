extends Node

var loadingSprite = preload("res://Art/UI/loading_cards.png")

var sprites : Array = []
var offset = 8

var timer = 0

func _ready():
	for j in range(2):
		for i in range(8):
			var sprite = Sprite.new()
			sprite.texture = loadingSprite
			sprite.region_enabled = true
			sprite.region_rect = Rect2(Vector2((56 - (8 * i)), 0), Vector2(8, 12))
			
			sprites.append(sprite)
			$SpinHolder.add_child(sprite)
		
		for i in range(4):
			sprites.append(null)

func _physics_process(delta):
	timer += delta
	
	var total = sprites.size()
	for i in range(sprites.size()):
		if sprites[i] != null:
			var angle = (float(i)/total + timer) * (PI * 2)
			sprites[i].position = Vector2(offset, 0).rotated(angle)
