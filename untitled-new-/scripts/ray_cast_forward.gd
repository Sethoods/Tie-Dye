extends RayCast2D

@export var posx_t := 0.0
@export var posx_o := 0.0
@export var posy_t := 0.0
@export var posy_o := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	position.x = posx_o
	position.y = posy_o
	target_position = Vector2(posx_t, posy_t)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
 
