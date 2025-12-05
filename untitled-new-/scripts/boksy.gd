extends CharacterBody2D

var speed: float = 100
var direction: int = 1
@onready var tilemap: TileMapLayer = get_node("/root/mylevel/Level_test")

func _physics_process(delta: float) -> void:
	velocity.y += get_gravity().y * delta
	velocity.x = speed * direction
	
	# Position ahead of the character’s feet
	var ahead_pos = global_position + Vector2(direction * 16, 16) # 16px offset forward & down
	var cell = tilemap.local_to_map(ahead_pos)
	
	# Check if there’s a tile underfoot
	var has_ground = tilemap.get_cell_source_id(cell) != -1
	
	if is_on_wall() or not has_ground:
		direction *= -1
	
	move_and_slide()
