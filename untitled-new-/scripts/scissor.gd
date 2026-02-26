extends StaticBody2D

@export var start_angle: float
var timer : float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rotation += start_angle


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta
	rotation = 3*sin(timer)+start_angle
