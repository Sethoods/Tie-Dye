extends CharacterBody2D

var speed: float = 100
var direction: int = 1
var counter:  bool = false
@onready var tilemap: TileMapLayer = get_node("/root/mylevel/Level_test")

func _physics_process(delta: float) -> void:
	counter = false
	velocity.y += get_gravity().y * delta
	velocity.x = speed * direction
	floor_max_angle=PI/2.1
	
	var ahead_cell = tilemap.local_to_map(global_position + Vector2(direction * 8, 0))

	for i in range(0,3):
			if tilemap.get_cell_source_id(ahead_cell + Vector2i(0, i)) != -1:
				counter = true
				#print(str(counter) + ", air below infront")
				break
				
	#var wall_cell = tilemap.local_to_map(global_position + Vector2(direction * 16, -8))
			
	if counter != true or $RayCastForward.is_colliding():
		scale.x *= -1
		direction *= -1
	
	move_and_slide()
