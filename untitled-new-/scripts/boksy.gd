extends CharacterBody2D

var speed: float = 100
var stun_timer : float = 0.0
var direction: int = 1
var counter:  bool = false
var stunned := false
@onready var tilemap: TileMapLayer = get_node("/root/mylevel/Level_test")

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
			print(self, "no longer stun")
			stunned = false
			stun_timer = 0.5
	
	move_and_slide()

func player_collided(collision: String) -> void:
	pass
	if collision == "top":
		print("stunned ", self.name)
		velocity = Vector2(0, 100)
		stunned = true
		stun_timer = .347
	elif collision == "face":
		direction *= -1
		scale.x *= -1
	elif collision == "slide":
		print("slid into", self.name)
		velocity = Vector2(0, -500)
		stunned = true
		stun_timer = 1.22

"""func _on_ev_p_collision_area_entered(area: Area2D) -> void:
	if not area.is_in_group("friendly hitbox"):
			return
			
	print("collided with", area)
	var enemshape : Shape2D=  $"EvP collision/Unique".shape
	var pshape : Shape2D =area.get_node("Collision normal").shape
		
	var enem_top : float = global_position.y - enemshape.size.y / 2
	var player_bottom: float = area.global_position.y + pshape.size.y / 2#(pshape.height + pshape.radius * 2) / 2
	
	if enem_top < player_bottom:
		print("stunned ", self.name)
		velocity = Vector2(0, 100)
		stunned = true
		stun_timer = 3.0
	else:
		direction *= -1"""
			
	
