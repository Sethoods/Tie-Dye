extends CharacterBody2D


const SPEED = 125.0
const JUMP_VELOCITY = -400.0

const MIN_ACCEL = 1
const MAX_ACCEL = 3
const RATE_GROWTH_ACCEL = 0.5

var direction := 0.0
var floor_angle := 0.0
var slope_dir: Vector2

var accel : float = 0.0
var rolling : bool = false
var roll_accel : float = 0.0

@export var proj_scene = preload("res://scenes/paper.tscn")
var shooting : bool = false

func animate(_delta: float) -> void:
	if velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
	if rolling == true:
		$AnimatedSprite2D.play("slide")
	else:
		if velocity.y == 0:
			if velocity.x == 0:
				$AnimatedSprite2D.play("default")
			else:
				$AnimatedSprite2D.play("move")
		else:
			$AnimatedSprite2D.play("jump")
	$AnimatedSprite2D.speed_scale = 1 + (accel-1)

func shoot(_delta: float):
	var player_proj = proj_scene.instantiate()
	player_proj.player = self
	get_parent().add_child(player_proj)
	player_proj.global_position = $Marker2D.global_position

func _physics_process(delta: float) -> void:
	floor_snap_length = 30 if rolling else 5
	floor_max_angle = PI/2.1
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		velocity.x -= velocity.x/10*delta

	#if Input.is_action_pressed("accelerate"):
	#	accel += RATE_GROWTH_ACCEL*delta
	#else:
	#	accel = move_toward(accel, 0, RATE_GROWTH_ACCEL*100*delta)

	accel = clamp(accel, MIN_ACCEL, MAX_ACCEL)		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_axis("move_left", "move_right")
	if direction:
		if not rolling:
			var max_movement_speed = SPEED * accel
			velocity.x = move_toward(velocity.x, max_movement_speed * direction+roll_accel, (SPEED * 10) * delta) 
			accel += RATE_GROWTH_ACCEL*delta
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
		
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY-((accel-1)*30)
		velocity.x = velocity.x
		rolling = false
		
	if Input.is_action_just_pressed("shoot") and not rolling:
		shooting = true
		shoot(delta)
		
		
	if Input.is_action_just_pressed("crouch") and is_on_floor():
		rolling = true
		
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
	if not rolling:
		roll_accel = move_toward(roll_accel, 0.0, 200 * delta)	
	
	animate(delta)
	move_and_slide()
