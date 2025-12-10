extends RayCast2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position.x = 8
	position.y = -8
	target_position = Vector2(8, 0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
