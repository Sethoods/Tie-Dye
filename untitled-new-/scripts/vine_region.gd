extends Area2D

var length : int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("hey I exist")
	$Sprite2D.region_enabled = true
	$Sprite2D.centered = false
	$Sprite2D.offset = Vector2i(-30, -30)
	
	var regy = 64*length
	$Sprite2D.region_rect = Rect2(0, 0, 64, regy)
	print($Sprite2D.region_rect)
	$CollisionShape2D.shape.size = $Sprite2D.region_rect.size*$Sprite2D.scale
	$CollisionShape2D.position = $Sprite2D.offset + ($Sprite2D.region_rect.size * $Sprite2D.scale) / 2
