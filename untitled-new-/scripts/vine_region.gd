extends Area2D

var length

func set_length(val: int):
	length = val
	make_vine()
	
func make_vine():
	$Sprite2D.region_enabled = true
	$Sprite2D.centered = false
	$Sprite2D.offset = Vector2(-30, -30)

	var regy = 64 * length
	$Sprite2D.region_rect = Rect2(0, 0, 64, regy)
	# Make sure the shape is unique and initialized
	$CollisionShape2D.shape = $CollisionShape2D.shape.duplicate()

# Now assign the correct size
	var vine_size = $Sprite2D.region_rect.size
	$CollisionShape2D.shape.size = vine_size*$Sprite2D.scale
	$CollisionShape2D.position.y += vine_size.y*$Sprite2D.scale.y/2-8

# Position it to match the sprite
	
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
