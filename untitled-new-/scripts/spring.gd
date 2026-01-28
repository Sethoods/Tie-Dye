extends Area2D

func direct(dir: Vector2i):
	rotation = atan2(dir.x, -dir.y)
	$RayCast2D.target_position = 50*Vector2(-dir.x, -dir.y)
