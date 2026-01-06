extends CharacterBody2D

var base_velocity:= Vector2.ZERO
var saved_dir := 1
var player
var id
var last_normal = Vector2.ZERO
var climb_dir = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	up_direction = Vector2.ZERO
	id = str(player.primary_dye) + str(player.secondary_dye)
	print(id)
	base_velocity = Vector2(250*player.proj_dir[0], -200*(player.proj_dir[1]))
	saved_dir=player.proj_dir[0]
	velocity.x += base_velocity.x + player.velocity.x
	velocity.y += base_velocity.y - 100
	
	$ProjSprite.region_enabled = true
	var regx = 60*player.primary_dye
	var regy = 60*player.secondary_dye
	$ProjSprite.region_rect = Rect2(regx, regy, 60, 60)
	
	if id == "100":
		$Timer.stop()
		$Timer.start(5)

func _physics_process(delta: float) -> void:
	
	if id == "100":
		floor_snap_length = 100
		var normal := Vector2.ZERO
		for i in range(get_slide_collision_count()):
			normal = get_slide_collision(i).get_normal()			
				
		if get_slide_collision_count() > 0:
			if normal != Vector2.ZERO:
				last_normal = normal
			else:
				normal = last_normal
				#print(snappedf(rad_to_deg(ground_angle), 0.01), " ",normal)
				
			var tangent = Vector2(normal.y, -normal.x).normalized()
				
			if tangent.dot(velocity) < 0:
					tangent = -tangent
					
			if climb_dir == Vector2.ZERO:
					climb_dir = tangent
				
			var proj_speed = velocity.length()		
			#print([snappedf(normal.x, 0.01), snappedf(normal.y, 0.01)]," ",[snappedf(tangent.x, 0.01) ,snappedf(tangent.y,0.01)]," ", proj_speed)				
			velocity = climb_dir*proj_speed
			velocity += -normal*50
			#print(velocity)
		else:
			climb_dir = Vector2.ZERO
			
			
	if not id == "100":
		velocity.y += get_gravity().y/2.5  * delta
	rotation += 20 * delta
	
	move_and_slide()

	

func _on_timer_timeout() -> void:
	queue_free()
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		if id == "100":
			return
		else:
			queue_free()
