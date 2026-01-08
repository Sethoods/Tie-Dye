extends CharacterBody2D

var speed: float = 100
var stun_timer : float = 0.0
var direction: int = 1
var counter:  bool = false
var stunned := false
var chills : int = 0
@onready var tilemap: TileMapLayer = get_node("/root/mylevel/Level_test")
@export var frozen = preload("res://scenes/frozemed.tscn")

func freeze():
	if chills > 2:
		var new_frozen = frozen.instantiate()
		get_parent().add_child(new_frozen)
		new_frozen.position = position
		print("ran this function ", new_frozen.global_position)
		queue_free()
	else:
		chills += 1

func _physics_process(delta: float) -> void:
	counter = false
	floor_max_angle=PI/2.1

	velocity.y += get_gravity().y * delta
	if stunned == false:
		velocity.x = speed * direction
		
		var ahead_cell = tilemap.local_to_map(global_position + Vector2(direction * 8, 0))

		for i in range(0,4):
				if tilemap.get_cell_source_id(ahead_cell + Vector2i(0, i)) != -1 and not $RayCastForward.is_colliding():
					counter = true
					#print(str(counter) + ", air below infront")
					break
					
		#var wall_cell = tilemap.local_to_map(global_position + Vector2(direction * 16, -8))
				
		if counter != true or $RayCastForward.is_colliding():
			scale.x *= -1
			direction *= -1
	elif stunned:
		stun_timer -= delta
		if stun_timer <= 0:
			#print(self, "no longer stun")
			stunned = false
			stun_timer = 0.5
	
	move_and_slide()

func player_collided(collision: String) -> void:
	pass
	if collision == "top":
		#print("stunned ", self.name)
		velocity = Vector2(0, 100)
		stunned = true
		stun_timer = .347
	elif collision == "face":
		direction *= -1
		scale.x *= -1
	elif collision == "slide":
		#print("slid into", self.name)
		velocity = Vector2(0, -500)
		stunned = true
		stun_timer = 1.22

func proj_collided(id: String) -> void:
	stunned = true
	stun_timer = .5
	match id:
		"20":
			velocity.x -= 2*velocity.x
			velocity.y = -200
		"50":
			pass
		_:
			velocity.x *= -0.43
			velocity.y = -200
