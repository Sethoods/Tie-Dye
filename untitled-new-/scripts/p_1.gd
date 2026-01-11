extends CharacterBody2D

const DYES ={
	"NULL" : 0,
	"FIRE" : 1,
	"COMBAT" : 2,
	"ELECTRIC" : 3,
	"PLANT" : 4,
	"AIR" : 5,
	"ICE" : 6,
	"WATER" : 7,
	"ELASTIC" : 8,
	"MYSTERY" : 9,
	"METAL" : 10
}

const SPEED = 75.0
const JUMP_VELOCITY = -330.0

const MIN_ACCEL = 1
const MAX_ACCEL = 5
const RATE_GROWTH_ACCEL = 0.5

var SHOOT_DELAY : float = .25

var direction := 0.0
var floor_angle := 0.0
var slope_dir : Vector2
var has_djumped : bool = false

var accel : float = 0.0
var rolling : bool = false
var roll_accel : float = 0.0

var proj_dir : Vector2
@export var proj_scene = preload("res://scenes/paper.tscn")
var shooting : bool = false
var shoot_timer : float = 0.0

var primary_dye : int = DYES["NULL"]
var secondary_dye : int = DYES["NULL"]

var is_hurt : bool = false
var hurt_timer : float = 0.0
var health : int = 0

var is_crouching : bool = false

func colorate(current_dye: Array):
	if current_dye[0] == DYES["NULL"] and current_dye[1] == DYES["NULL"]:
		$AnimatedSprite2D.material.set("shader_parameter/fill_color", Color(0.95, 0.95, 0.95, 1.0))
	elif current_dye[0] != DYES["NULL"] and current_dye[1] == DYES["NULL"]:
		match current_dye[0]:
			DYES["FIRE"]:
				$AnimatedSprite2D.material.set("shader_parameter/fill_color", Color(1.0, 0.0, 0.0, 1.0))
			DYES["COMBAT"]:
				$AnimatedSprite2D.material.set("shader_parameter/fill_color", Color(1.0, 0.5, 0.2, 1.0))
			DYES["ELECTRIC"]:
				$AnimatedSprite2D.material.set("shader_parameter/fill_color", Color(1.0, 1.0, 0.0, 1.0))
			DYES["PLANT"]:
				$AnimatedSprite2D.material.set("shader_parameter/fill_color", Color(0.0, 1.0, 0.0, 1.0))
			DYES["AIR"]:
				$AnimatedSprite2D.material.set("shader_parameter/fill_color", Color(0.0, 0.5, 0.4, 1.0))
			DYES["ICE"]:
				$AnimatedSprite2D.material.set("shader_parameter/fill_color", Color(0.0, 1.0, 1.0, 1.0))
			DYES["WATER"]:
				$AnimatedSprite2D.material.set("shader_parameter/fill_color", Color(0.0, 0.0, 1.0, 1.0))
			DYES["ELASTIC"]:
				$AnimatedSprite2D.material.set("shader_parameter/fill_color", Color(0.5, 0.0, 0.5, 1.0))
			DYES["MYSTERY"]:
				$AnimatedSprite2D.material.set("shader_parameter/fill_color", Color(1.0, 0.0, 1.0, 1.0))
			DYES["METAL"]:
				$AnimatedSprite2D.material.set("shader_parameter/fill_color", Color(0.6, 0.6, 0.6, 1.0))

	

func animate(_delta: float) -> void:
	if velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
	if shooting:
		return
	if is_hurt:
		return
	if is_crouching:
		return
	if rolling == true:
		if velocity.y < 0:
			$AnimatedSprite2D.play("slide up")
		elif velocity.y > 0:
			$AnimatedSprite2D.play("slide down")
		else:
			$AnimatedSprite2D.play("slide neutral")
	else:
		if velocity.y == 0:
			if velocity.x == 0:
				$AnimatedSprite2D.play("default")
			else:
				if velocity.x <= 250 and velocity.x >= -250:
					$AnimatedSprite2D.play("move")
				else:
					$AnimatedSprite2D.play("panic")
		else:
			if has_djumped:
				$AnimatedSprite2D.play("float")
			else:
				if velocity.y < 0:
					$AnimatedSprite2D.play("jump")
				else:
					$AnimatedSprite2D.play("fall")
	$AnimatedSprite2D.speed_scale = 1 + (accel/2)

func power_up(paint_type: int):
	match paint_type:
		1:
			primary_dye = DYES["FIRE"]
		2:
			primary_dye = DYES["COMBAT"]
		3:
			primary_dye = DYES["ELECTRIC"]
		4:
			primary_dye = DYES["PLANT"]
		5:
			primary_dye = DYES["AIR"]
		6:
			primary_dye = DYES["ICE"]
		7:
			primary_dye = DYES["WATER"]
		8:
			primary_dye = DYES["ELASTIC"]
		9:
			primary_dye = DYES["MYSTERY"]
		10:
			primary_dye = DYES["METAL"]
	colorate([primary_dye, secondary_dye])
	print("You have the ", DYES.find_key(primary_dye), " Dye")

func shoot():
	var player_proj = proj_scene.instantiate()
	player_proj.player = self
	get_parent().add_child(player_proj)
	player_proj.global_position = $Marker2D.global_position

func _on_pv_e_collision_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemy Hitboxes"):
		var pshape = $"PvE collision/Collision normal".shape as RectangleShape2D
		var enemshape = area.get_node("Unique").shape as RectangleShape2D
			
		var enem_top : float = area.get_node("Unique").global_position.y - enemshape.size.y / 2 
		var player_bottom: float = $"PvE collision/Collision normal".global_transform.origin.y + pshape.size.y / 2#(pshape.height + pshape.radius * 2) / 2
			
		if not rolling:
			if player_bottom - 5 < enem_top or velocity.y > 0:
				velocity.y = -300
				print("YES!")
				area.get_parent().player_collided("top")
			else:
				velocity += Vector2(-direction*100*min(2, max(1, accel)), -50)
				if not is_crouching:
					accel = 0
				print("ouch")
				area.get_parent().player_collided("face")
				is_hurt = true
				hurt_timer = 0
				$AnimatedSprite2D.play("ouch")
				if direction < 0:
					$AnimatedSprite2D.flip_h = true
					

			#print(player_bottom,"   ", enem_top)
		else:
			print("slide")
			area.get_parent().player_collided("slide")

func _input(_event: InputEvent) -> void:
	if _event.is_action_pressed("move_left") or _event.is_action_pressed("move_right") or _event.is_action_pressed("crouch") or _event.is_action_pressed("up"):
		proj_dir = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("crouch", "up"))

func _physics_process(delta: float) -> void:
	colorate([primary_dye, secondary_dye])
	floor_snap_length = 30 if rolling else 10
	floor_max_angle = PI/2.1
	
	if is_crouching or has_djumped:
		$"PvE collision/Crouch".set_deferred("disabled", false)
		$"PvE collision/Collision normal".set_deferred("disabled", true)
		$GroundCollision.set_deferred("disabled", true)
		$Crouch2.set_deferred("disabled", false)
	else:
		$"PvE collision/Crouch".set_deferred("disabled", true)
		$"PvE collision/Collision normal".set_deferred("disabled", false)
		$GroundCollision.set_deferred("disabled", false)
		$Crouch2.set_deferred("disabled", true)
	
	if is_hurt:
		hurt_timer += delta
		if hurt_timer > 1:
			hurt_timer = 0
			is_hurt = false
	#var recent_input := 
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity()/1.5 * delta if has_djumped == false else get_gravity()/3 * delta
		velocity.x -= velocity.x/10*delta
	elif is_on_floor():
		has_djumped = false

	accel = clamp(accel, MIN_ACCEL, MAX_ACCEL)		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay action
	var prev_dir := direction
	direction = Input.get_axis("move_left", "move_right")
	if direction == 0:
		direction = prev_dir
		prev_dir = 0
	if direction and prev_dir and not is_hurt:
		if not rolling:
			var max_movement_speed = SPEED * accel
			velocity.x = move_toward(velocity.x, max_movement_speed * direction+roll_accel, (SPEED * 5) * delta) 
			if is_crouching:
				velocity.x /= 1.5
			accel += RATE_GROWTH_ACCEL*delta*2
		else:
			if velocity.x < 0.1 or velocity.x > -0.1:
				if velocity.x >= 0.1 and direction < 0 or velocity.x <= 0.1 and direction > 0 :
					rolling = false
			else:
				velocity.x -= -velocity.x*delta
			
#		print("%s"%[slope_dir])
	elif not rolling and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, SPEED)
		accel = move_toward(accel, 0, RATE_GROWTH_ACCEL*100*delta)
		
		
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_crouching:
		velocity.y = JUMP_VELOCITY-((accel-1)*7.5)
		velocity.x = velocity.x
		rolling = false
		if is_hurt:
			hurt_timer = 0
			is_hurt = false
	elif Input.is_action_just_pressed("jump") and not is_on_floor() and not has_djumped and not is_hurt:
		velocity.y = JUMP_VELOCITY/2
		has_djumped = true
	
	if shooting:
		shoot_timer += delta
		if shoot_timer > SHOOT_DELAY:
			shooting = false
			shoot_timer = 0
	
	if Input.is_action_just_pressed("shoot") and not rolling and shoot_timer <= 0 and not is_hurt and not has_djumped:
		is_crouching = false
		var current_dye = [primary_dye, secondary_dye]
		match current_dye:
			[0, 0], [1, 0], [3,0], [4,0], [5,0], [6,0], [7,0]:
				SHOOT_DELAY = 0.25
				$ProjDelay.wait_time = SHOOT_DELAY*0.03
			[2, 0], [8,0], [9,0]:
				SHOOT_DELAY = 1
				$ProjDelay.wait_time = 0.001
			[10, 0]:
				SHOOT_DELAY = .5
				$ProjDelay.wait_time = SHOOT_DELAY*0.03
		shooting = true
		if primary_dye == DYES["COMBAT"] and secondary_dye == DYES["NULL"]:
			$AnimatedSprite2D.play("spinthrow")
		else:
			if velocity.x == 0:
				$AnimatedSprite2D.play("throw")
			else:
				$AnimatedSprite2D.play("movethrow")
		$ProjDelay.start()

		
		
	if Input.is_action_just_pressed("crouch") and is_on_floor() and velocity.x != 0:
		rolling = true
	elif Input.is_action_pressed("crouch") and not shooting and not has_djumped and not rolling: 
		is_crouching = true
		$AnimatedSprite2D.play("duck")
	else:
		is_crouching = false
		
	if 	rolling and is_on_floor():
		var floor_normal = get_floor_normal()
		var ground_angle = rad_to_deg(floor_normal.angle_to((Vector2.UP)))
		if ground_angle > 2 or ground_angle < -2:
			roll_accel = min(roll_accel + 10 * delta, 2000) 
		else:
			roll_accel = 1
		var tangent = Vector2(floor_normal.y, -floor_normal.x).normalized()
		if tangent.dot(Vector2.DOWN) < 0:
			tangent = -tangent
		slope_dir = Vector2(0,1).project(tangent).normalized()
		velocity +=  slope_dir * (200 * roll_accel) * delta
	if not rolling and not direction:
		roll_accel = move_toward(roll_accel, 0.0, 200 * delta)
	
	animate(delta)
	move_and_slide()


func _on_proj_delay_timeout() -> void:
		shoot()
		$ProjDelay.stop()
