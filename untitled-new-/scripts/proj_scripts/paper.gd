extends Area2D

var velocity := Vector2.ZERO

var base_velocity := Vector2.ZERO

var saved_velocity := Vector2.ZERO

var player
var id
var last_normal = Vector2.ZERO
var charge := 0.0
var spin_timer := 0.0
var angle := 0.0 
var can_spin = true
var is_burning = false
var is_freezing = false
var is_shocking = false
var is_healing = false
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

func  child_proj(prid: String):			
	var c_proj = cluster.instantiate()
	c_proj.player = self
	c_proj.id = prid
	get_parent().call_deferred("add_child",c_proj)
	c_proj.global_position = position

func _ready() -> void:
	if id != "E0" and id != "B0":
		id = str(player.primary_dye) + str(player.secondary_dye)
		#print(id)
		base_velocity = Vector2(125*player.proj_dir[0], -200*(player.proj_dir[1]))
		#print(base_velocity)
		velocity.x += base_velocity.x + player.velocity.x
		velocity.y += base_velocity.y
	elif id == "B0":
		velocity=Vector2.ZERO
		is_gravity = false
		is_burning = true
	else:
		velocity.x = randi_range(-300, 300)
		velocity.y = randi_range(-300, 300)
		scale *= 0.5

	match id:
		"10":
			is_burning = true
			velocity.x *= 2
			if player.proj_dir[0] == 0:
				velocity.x = 600
		"12", "21":
			can_spin = false
			global_rotation = asin(player.direction)

			is_burning = true
			velocity.x *= 4
			velocity.y += randf_range(-100, 100)
			rotation += randf_range(-360, 360)
			scale = Vector2(0.5, 0.5)
			if player.proj_dir[0] == 0:
				velocity.x = 600
		"13", "31":
			is_shocking = true
			is_burning = true
			velocity = Vector2.ZERO
			is_gravity = false
			scale *= 2
			$Timer.stop()
			$Timer.start(20)
		"14", "41":
			is_burning = true
			is_healing = true
		"15", "51":
			is_burning = true
			is_gravity = false
			can_spin = false
			$Timer.stop()
			$Timer.start(1)
		"16", "61":
			charge = player.proj_charge
			velocity.x /= 2
			print(charge)
			velocity.x += velocity.normalized().x * (50*charge)
			scale *= charge
			is_gravity = false
			$Timer.start($Timer.time_left+charge/2)
			player.proj_charge = 0.0
		"17", "71":
			can_spin = false
			$ProjSprite.rotation += 45
			velocity.y = 40
			is_gravity = false
			$PaperRay.enabled = true
			$PaperRay.target_position = Vector2(-cos(rotation), sin(rotation))
		"20":
			scale *= 2
			velocity.y += -100
			velocity.x /= 2
			saved_velocity = velocity
			$Timer.stop()
			$Timer.start(7)
		"30":
			is_gravity = false
			is_shocking = true
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
			is_healing = true
		"50":
			is_gravity = false
			velocity /= 2
			$Timer.stop()
			$Timer.start(5)
		"60":
			velocity.x /= 1.25
			is_freezing = true
			velocity.x *= 1.15
		"70":
			$Timer.stop()
			$Timer.start(1)
		"80":
			$PaperRay.enabled = true
			$PaperRay.target_position = Vector2(velocity.x/30, velocity.y/30)
			$Timer.stop()
			$Timer.start(15)
		"90":
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
		_:
			pass
	
	$ProjSprite.region_enabled = true
	if id != "E0" and id != "B0":
		var regx = 60*player.primary_dye
		var regy = 60*player.secondary_dye
		$ProjSprite.region_rect = Rect2(regx, regy, 60, 60)
		#print($ProjSprite.region_rect)
		
		if player.proj_dir[1] == 0 and is_gravity == true:
			velocity.y -= 100
	elif id == "B0":
		var regx = 60*14
		var regy = 60*1
		$ProjSprite.region_rect = Rect2(regx, regy, 60, 60)
	else:
		var regx = 60*14
		var regy = 60*4
		$ProjSprite.region_rect = Rect2(regx, regy, 60, 60)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:	
	match id:
		"20":
			spin_timer += delta
			if $Timer.time_left >6:
				can_spin = false
				var osc = 12*cos(30*(spin_timer))
				position.y = player.global_position.y - 10
				position.x = player.global_position.x + osc
				is_gravity = false
			else:
				if saved_velocity != Vector2.ZERO:
					can_spin = true
					is_gravity = true
					velocity = saved_velocity
					velocity.x += player.velocity.x
					saved_velocity = Vector2.ZERO
		"13","31":
			print(get_tree().get_nodes_in_group("Projectile").size())
			if get_tree().get_nodes_in_group("Projectile").size() > 1:
				queue_free()
			var plasma_dir = Input.get_axis("move_left", "move_right")
			if Input.is_action_pressed("up"):
				velocity.y += -200*delta
			if Input.is_action_pressed("crouch"):
				velocity.y += 200*delta
			velocity.x = move_toward(velocity.x, 450*plasma_dir, 200*delta)
			if plasma_dir==0 and not Input.is_action_pressed("crouch") and not Input.is_action_pressed("up"):
				velocity = Vector2( move_toward(velocity.x, 0, 100*delta),move_toward(velocity.y, 0, 200*delta))
				if velocity == Vector2.ZERO and $Timer.time_left < 19:
					queue_free()
			else:
				player.velocity = Vector2.ZERO
		"15", "51":
			if $Timer.time_left > 0.5:
				scale.y += 5*delta
			else:
				scale.y -= 2*delta
			scale.x += delta
			velocity.x = move_toward(velocity.x, 0, 50*delta)
		"16", "61":
			velocity.x = move_toward(velocity.x, 0, 50*delta)
			velocity.y -= 30*delta
		"17", "71":
			var normal := Vector2.ZERO
			if $PaperRay.is_colliding():
				normal = $PaperRay.get_collision_normal()	
				var proj_tangent = apply_normal(normal, delta, $PaperRay)
				var proj_speed = velocity.length()		
				velocity = proj_tangent*proj_speed
			#else:
			#	var proj_tangent = apply_normal(normal, delta, $Metal)
			#	var proj_speed = velocity.length()		
			#	velocity = proj_tangent*proj_speed
		"30":
			spin_timer += delta
			var osc = 15*cos(35*(spin_timer))
			position.y += osc
		"40":
			if base_velocity.x >= 0:
				velocity.x -= delta*200
			else:
				velocity.x += delta*200
			if base_velocity.x/velocity.x > 0:
				velocity.y -= delta*60
			else:
				velocity.y += delta*80
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
		"90":
			spin_timer += delta * player.velocity.x
			if $Timer.time_left >1:
				angle += delta * 20
				position.y = player.global_position.y + sin(angle) * (30 + abs(player.velocity.x)/5)
				position.x = player.global_position.x + cos(angle) * (20 + abs(player.velocity.x)/3)
				is_gravity = false
			else:
				if saved_velocity != Vector2.ZERO:
					is_gravity = true
					velocity = saved_velocity
					velocity.x += player.velocity.x
					saved_velocity = Vector2.ZERO
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
		"B0":
			scale.y += 0.1
			position.y -= 10*delta
		_:
			pass
			
	if is_gravity:
		velocity.y += 250  * delta
	if is_gravity or id == "10" or id == "40":
		pass
	if can_spin:
		$ProjSprite.rotation_degrees += 2000*delta
		$CollisionShape2D.rotation_degrees += 2000*delta
	position += velocity * delta

func _on_timer_timeout() -> void:
	if id == "70":
		for  i in range(8):
			child_proj("E0")
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		match id:
			"20","30","13","31","15","51","16","61","17","71","50","80","90", "100", "B0":
				return
			"14","41":
				child_proj("B0")
				queue_free()
			"70":
				for  i in range(5):
					child_proj("E0")
				queue_free()
			_:
				queue_free()
	if id == "80":
		velocity.x *= randi_range(-2, 2)
		velocity.y *= randi_range(-2, 2)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemy Hitboxes"):
		var boksy = area.get_parent() as CharacterBody2D
		if not id == "30" and not id == "80" and not id == "13" and not id == "31"  and not id == "15"  and not id == "51"  and not id == "16"  and not id == "61":
			#print(id+ " destroyed")
			queue_free()
			if id == "20" or id == "90":
				player.shooting = false
				player.shoot_timer = 0
		if is_freezing:
			boksy.freeze()
			queue_free()
		if is_burning:
			boksy.burn()
		if is_shocking:
			boksy.shock(0, position)

		if is_healing:
			player.health += boksy.health /4
		if id == "70":
			for  i in range(8):
					call_deferred("child_proj")
			
			
		boksy.proj_collided(id)
