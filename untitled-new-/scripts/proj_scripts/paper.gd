extends Area2D

var velocity := Vector2.ZERO

var base_velocity := Vector2.ZERO

var saved_velocity := Vector2.ZERO

var player
var id
var last_normal = Vector2.ZERO
var spin_timer := 0.0
var is_burning = false
var is_gravity = true

func apply_normal(normal: Vector2, delta: float, cast: RayCast2D) -> Vector2:
			if normal != Vector2.ZERO:
				last_normal = normal
			else:
				normal = last_normal
			if cast == $Metal:
				velocity += -normal*200*delta
			$Metal.target_position = -normal * max(10, velocity.length() * delta * 2)
			$Metal.position = normal * 2

			velocity.x = clampf(velocity.x, -200, 200)
			velocity.y = clampf(velocity.y, -200, 200)

				#print(snappedf(rad_to_deg(ground_angle), 0.01), " ",normal)
			var tangent = Vector2(normal.y, -normal.x).normalized()
				
			if tangent.dot(velocity) < 0:
					tangent = -tangent
			$PaperRay.target_position = tangent * max(12, velocity.length() * delta * 2)
			return tangent

func _ready() -> void:
	id = str(player.primary_dye) + str(player.secondary_dye)
	#print(id)

	base_velocity = Vector2(150*player.proj_dir[0], -200*(player.proj_dir[1]))
	print(base_velocity)
	velocity.x += base_velocity.x + player.velocity.x
	velocity.y += base_velocity.y
	
	match id:
		"10":
			is_burning = true
			is_gravity = false
			velocity.x *= 2
			if player.proj_dir[0] == 0:
				velocity.x = 200
		"20":
			velocity.y += -100
			velocity.x /= 2
			saved_velocity = velocity
			$Timer.stop()
			$Timer.start(7)			
		"100":
			$Metal.enabled = true
			$PaperRay.enabled = true
			$Metal.target_position = Vector2(velocity.x/50, velocity.y/50)
			$PaperRay.target_position = Vector2(velocity.x/50, velocity.y/50)

			$Timer.stop()
			$Timer.start(6)
			is_gravity = false
	
	$ProjSprite.region_enabled = true
	var regx = 60*player.primary_dye
	var regy = 60*player.secondary_dye
	$ProjSprite.region_rect = Rect2(regx, regy, 60, 60)	
		
	if player.proj_dir[1] == 0 and is_gravity == true:
		velocity.y -= 100

	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:	
	if id == "10":
		pass
	elif id == "20":
		spin_timer += delta
		if $Timer.time_left >6:
			var osc = 12*cos(16*(spin_timer))
			position.y = player.global_position.y - 2
			position.x = player.global_position.x + osc
			is_gravity = false
		else:
			if saved_velocity != Vector2.ZERO:
				is_gravity = true
				velocity = saved_velocity
				velocity.x += player.velocity.x
				saved_velocity = Vector2.ZERO

	elif id == "100":
		var normal := Vector2.ZERO
				
			#print([snappedf(normal.x, 0.01), snappedf(normal.y, 0.01)]," ",[snappedf(tangent.x, 0.01) ,snappedf(tangent.y,0.01)]," ", proj_speed)				
		if $Metal.is_colliding():
			normal = $Metal.get_collision_normal()
			if $PaperRay.is_colliding():
				normal = $PaperRay.get_collision_normal()	
				var proj_tangent = apply_normal(normal, delta, $PaperRay)
				
				var proj_speed = velocity.length()		
				velocity = proj_tangent*proj_speed
			else:
				var proj_tangent = apply_normal(normal, delta, $Metal)
				
				var proj_speed = velocity.length()		
				velocity = proj_tangent*proj_speed
		else:
			$Metal.target_position = Vector2(velocity.x/50, velocity.y/50)
			
	if is_gravity:
		velocity.y += 250  * delta
		rotation += 20 * delta
	position += velocity * delta


func _on_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		match id:
			"20", "100":
				return
			_:
				queue_free()
