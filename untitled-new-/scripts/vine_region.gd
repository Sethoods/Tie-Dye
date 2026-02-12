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
	$CollisionShape2D.shape.size =  $Sprite2D.region_rect.size*$Sprite2D.scale
	$CollisionShape2D.position.y += $Sprite2D.region_rect.size.y*$Sprite2D.scale.y/2-8

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("friendly hitbox"):
		var player = area.get_parent()
		if player.is_wheel == false:
			player.climb_state(true)
