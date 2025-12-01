extends Marker2D

var pos_offset := Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_parent().direction >= 0:
		pos_offset = Vector2(1, 0)
	else:
		pos_offset = Vector2(-1, 0)
	position = pos_offset
