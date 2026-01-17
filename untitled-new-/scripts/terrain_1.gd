extends TileMapLayer

var vine_scene = preload("res://scenes/vine.tscn")
# Called when the node enters the scene tree for the first time.
func instantiate_scene(scene: Resource, this_position: Vector2, length: int):
	var vine = scene.instantiate()
	#print("vine exists")
	vine.position = map_to_local(this_position)
	vine.set_length(length)
	add_child(vine)
	#print(vine.global_position)

func _ready() -> void:
	await get_tree().process_frame
	var vine_array = get_used_cells_by_id(-1,Vector2i(0,4))
	vine_array.append_array(get_used_cells_by_id(-1,Vector2i(1,4)))
	#print(vine_array))
	
	for vine_pos : Vector2i in vine_array:
		var vine_loops := 0
		var ahead_pos := vine_pos
		while vine_loops < 10:
			if get_cell_source_id(ahead_pos + Vector2i(0, 1)) == -1:
				ahead_pos.y += 1
				vine_loops += 1
				continue

			var is_solid = get_cell_tile_data(ahead_pos + Vector2i(0, 1))
			if is_solid and is_solid.get_custom_data("is_solid"):
				break

			ahead_pos.y += 1
			vine_loops += 1

		#print(vine_pos,vine_loops)
		instantiate_scene(vine_scene, vine_pos, vine_loops)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
