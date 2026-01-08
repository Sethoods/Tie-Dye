extends Area2D

var velocity := Vector2.ZERO

var base_velocity := Vector2.ZERO

var saved_velocity := Vector2.ZERO

var player
var id
var last_normal = Vector2.ZERO
var spin_timer := 0.0
var angle := 0.0 
var is_burning = false
var is_gravity = true
@export var cluster = preload("res://scenes/paper.tscn")

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

func  child_proj():			
	var droplet = cluster.instantiate()
	droplet.player = self
	droplet.id = "E0"
	get_parent().add_child(droplet)
	droplet.global_position = position

func _ready() -> void:
	if id != "E0":
		id = str(player.primary_dye) + str(player.secondary_dye)
		print(id)
		base_velocity = Vector2(150*player.proj_dir[0], -200*(player.proj_dir[1]))
		#print(base_velocity)
		velocity.x += base_velocity.x + player.velocity.x
		velocity.y += base_velocity.y
	else:
		velocity.x = randi_range(-300, 300)
		velocity.y = randi_range(-300, 300)
		scale *= 0.5

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
		"30":
			is_gravity = false
			velocity.x *= 2
			if player.proj_dir[0] == 0:
				velocity.x = 200
		"40":
			is_gravity = false
			velocity.x /= 1.2
			#velocity.y += 20
			if player.proj_dir[0] == 0:
				velocity.x = 200
			$Timer.stop()
			$Timer.start(6)
		"50":
			is_gravity = false
			velocity /= 2
			$Timer.stop()
			$Timer.start(5)
		"70":
			$Timer.stop()
			$Timer.start(1)
		"80":
			$PaperRay.enabled = true
			$PaperRay.target_position = Vector2(velocity.x/30, velocity.y/30)
		"100":
			$Metal.enabled = true
			$PaperRay.enabled = true
			$Metal.target_position = Vector2(velocity.x/50, velocity.y/50)
			$PaperRay.target_position = Vector2(velocity.x/50, velocity.y/50)

			$Timer.stop()
			$Timer.start(6)
			is_gravity = false
		_:
			pass
	
	$ProjSprite.region_enabled = true
	if id != "E0":
		var regx = 60*player.primary_dye
		var regy = 60*player.secondary_dye
		$ProjSprite.region_rect = Rect2(regx, regy, 60, 60)
		
		if player.proj_dir[1] == 0 and is_gravity == true:
			velocity.y -= 100
	else:
		var regx = 60*6
		var regy = 60*1
		$ProjSprite.region_rect = Rect2(regx, regy, 60, 60)
		
	

	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:	
	match id:
		"20":
			spin_timer += delta
			if $Timer.time_left >6:
				var osc = 12*cos(20*(spin_timer))
				position.y = player.global_position.y - 2
				position.x = player.global_position.x + osc
				is_gravity = false
			else:
				if saved_velocity != Vector2.ZERO:
					is_gravity = true
					velocity = saved_velocity
					velocity.x += player.velocity.x
					saved_velocity = Vector2.ZERO
		"30":
			spin_timer += delta
			var osc = 15*cos(25*(spin_timer))
			position.y += osc
		"40":
			if base_velocity.x >= 0:
				velocity.x -= delta*200
			else:
				velocity.x += delta*200
			if base_velocity.x/velocity.x > 0:
				velocity.y -= delta*60
			else:
				velocity.y += delta*70
		"50":
			var motion_origin = position
			spin_timer += delta
			angle += delta * 20
			var spiral_distance : float = delta * 625
			position.x = motion_origin.x + spiral_distance * cos(angle)
			position.y = motion_origin.y + spiral_distance * sin(angle)
			motion_origin.x += velocity.x*delta**2
		"80":
			var normal := Vector2.ZERO
			$PaperRay.target_position = Vector2(velocity.x/50, velocity.y/50)
			if $PaperRay.is_colliding():
				normal = $PaperRay.get_collision_normal()
				var speed = velocity.length()
				velocity = normal * speed
		"100":
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
		_:
			pass
			
	if is_gravity:
		velocity.y += 250  * delta
	if is_gravity or id == "10" or id == "40":
		pass
	$ProjSprite.rotation_degrees += 2000*delta
	$CollisionShape2D.rotation_degrees += 2000*delta
	position += velocity * delta

func _on_timer_timeout() -> void:
	if id == "70":
		for  i in range(8):
			child_proj()
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		match id:
			"20","30","50","80", "100":
				return
			"70":
				for  i in range(5):
					child_proj()
				queue_free()
			_:
				queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemy Hitboxes"):
		var boksy = area.get_parent() as CharacterBody2D
		if not id == "30" or id != "80":
			print(id)
			queue_free()
		if id == "60":
			boksy.freeze()
			queue_free()
		if id == "70":
			for  i in range(8):
					child_proj()
		if id == "80":
			if velocity.y > boksy.velocity.y:
				velocity.y *= -1
			velocity.y *= -1
			
			
		boksy.proj_collided(id)
