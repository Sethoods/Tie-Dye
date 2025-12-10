extends CharacterBody2D

var speed: float = 100
var direction: int = 1
var counter:  bool = false
@onready var tilemap: TileMapLayer = get_node("/root/mylevel/Level_test")

func _physics_process(delta: float) -> void:
	counter = false
	velocity.y += get_gravity().y * delta
	velocity.x = speed * direction
	
	var ahead_cell = tilemap.local_to_map(global_position + Vector2(direction * 16, 16))

	for i in range(0,6):
			if tilemap.get_cell_source_id(ahead_cell + Vector2i(0, i)) != -1:
				counter = true
				print(str(counter) + ", air below infront")
				break
				
	var wall_cell = tilemap.local_to_map(global_position + Vector2(direction * 16, -8))

	var wall_ahead := tilemap.get_cell_source_id(wall_cell) != -1


			
	if counter != true or wall_ahead:
		direction *= -1
	
	move_and_slide()
