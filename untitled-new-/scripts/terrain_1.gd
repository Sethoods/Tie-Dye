extends TileMapLayer

var vine_scene = preload("res://scenes/vine.tscn")
var fan_scene = preload("res://scenes/fan.tscn")
# Called when the node enters the scene tree for the first time.
func instantiate_scene(scene: Resource, this_position: Vector2, value, entity : String):
	var element = scene.instantiate()
	#print("vine exists")
	element.position = map_to_local(this_position)
	print(element.position)
	match entity:
		"Vine":
			element.set_length(value)
		"Fan":
			element.direct(value)
	add_child(element)
	#print(vine.global_position)
	
func get_array_tiles(coord_one: Vector2i, coord_two: Vector2i):
	await get_tree().process_frame
	var tile_array = get_used_cells_by_id(-1,coord_one)
	if coord_two != Vector2i.ZERO:
		tile_array.append_array(get_used_cells_by_id(-1,coord_two))
	return(tile_array)


func _ready() -> void:
	#print(vine_array))
	
	for vine_pos : Vector2i in await get_array_tiles(Vector2i(0,4), Vector2i(1,4)):
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
		instantiate_scene(vine_scene, vine_pos, vine_loops, "Vine")
	
	for fan_pos : Vector2i in await get_array_tiles(Vector2i(2,4),Vector2i(3,4)):
		var cell_list = get_surrounding_cells(fan_pos)
		var cell_normal := Vector2i.ZERO

		for cell in cell_list:
			var is_solid = get_cell_tile_data(cell)
			if is_solid and is_solid.get_custom_data("is_solid"):
				cell_normal = fan_pos-Vector2i(cell)
				print(cell_normal)
		instantiate_scene(fan_scene, fan_pos, cell_normal, "Fan")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
