extends CharacterBody2D

var speed: float = 50
var rot_effect_timer := 0.0
var stun_timer : float = 0.0
var direction: int = 1
var health : float = 10
var at_ledge:  bool = false
var is_gravity: bool = true
var stunned := false
var chills : int = 0
var burndedness: int = 0
var shocks : int = 0
var shock_timer : float = 0.5
@onready var tilemap: TileMapLayer = get_node("/root/mylevel/Level_test")
@export var frozen = preload("res://scenes/entities/frozemed.tscn")
@export var rot_dir = 1
var effect_temp = preload("res://art/lightningfekt ph.png")
var time_extant = 0
var cast
var wind_pushing := false
var ray_sine : float

func shock(numero: int, original_pos: Vector2):
	if numero < 3:
		numero = 0
		return
	shocks = numero
	if time_extant > shock_timer:
		time_extant = 0
		return
	var lightning = Line2D.new()
	lightning.width = 3.0
	lightning.default_color = Color.YELLOW
	get_parent().add_child(lightning)
	
	health -= 0.5
	lightning.add_point(original_pos)
	lightning.add_point(position)
	await get_tree().create_timer(1).timeout
	lightning.queue_free()
	$AOE.set_deferred("monitoring", true)
	await get_tree().create_timer(0.2).timeout
	$AOE.set_deferred("monitoring", false)

func freeze():
	if chills > 2 or health <= 0:
		var new_frozen = frozen.instantiate()
		get_parent().add_child(new_frozen)
		new_frozen.position = position
		queue_free()
	else:
		chills += 1
		
func burn():
	burndedness += 1
	print("ok it started burning")
	await get_tree().create_timer(8).timeout
	burndedness = 0
	print("ok it stopped burning")
	
func die():
	print("This enemy died")
	health = 10
	stunned = true
	stun_timer = 50
	velocity = Vector2.ZERO

func wind_state(state: bool, delta):
	if state == true:
		velocity.y += -300*cast.target_position.y*delta
		velocity.x += -100*cast.target_position.x*delta
	if state == false:
		pass

func _physics_process(delta: float) -> void:
	#if !$RayCastForward.is_colliding():
	#	ray_sine += 5*delta
	#	$RayCastForward.target_position.y += 4*cos(ray_sine)
	#else:
	#	ray_sine += 0.5*delta
	#	$RayCastForward.target_position.y += 4*cos(ray_sine)	

	time_extant += delta
	if health <= 0:
		die()
	at_ledge = false
	floor_max_angle=PI/2.1

	wind_state(wind_pushing, delta)
	if stunned == false:
		velocity.x = speed * direction
		
		
#		var ahead_cell = tilemap.local_to_map(global_position + Vector2(direction * 8, 0))

#		for i in range(0,4):
#				var is_solid = tilemap.get_cell_tile_data(ahead_cell + Vector2i(0, i))
#				if is_solid and is_solid.get_custom_data("is_solid"):
				#if tilemap.get_cell_source_id(ahead_cell + Vector2i(0, i)) != -1 :#and not $RayCastForward.is_colliding():
#					at_ledge = true
#					break
					
		#var wall_cell = tilemap.local_to_map(global_position + Vector2(direction * 16, -8))
			
		
		#if velocity.x == 0:
		#	velocity.y = -100
			#if Time.get_ticks_msec() % 5 == 0:
				#print($RayCastForward.get_collision_normal())
		#var normal = $RayCastForward.get_collision_normal() as Vector2
		#var tangent = Vector2(-normal.y, normal.x)
		
		#if tangent != Vector2.ZERO:
		#	velocity = tangent*60

		#var vec_angle_tuple = Vector2(cos(normal.angle_to(Vector2.RIGHT)), sin(normal.angle_to(Vector2.RIGHT)))
		
		if $RayCastForward.is_colliding():
			rot_effect_timer = 0
			#global_position = lerp(global_position, $RayCastForward.get_collision_point(), 20*delta)
			var normal = $RayCastForward.get_collision_normal() 
			rotation = lerp_angle(rotation, atan2(normal.y, normal.x), delta/5)
			velocity = 60*Vector2(cos(rotation), sin(rotation+0.26))
		else:
			rot_effect_timer += delta/8
			velocity /= 3
			rotation += 3*delta*rot_dir+rot_effect_timer
			if rot_effect_timer > .25:
				velocity.y += 100
			
	elif stunned:
		stun_timer -= delta
		if stun_timer <= 0:
			#print(self, "no longer stun")
			stunned = false
			stun_timer = 0.5
	
					
	if burndedness > 0:
		$Sprite2D.visible = true
		velocity.x += delta*200*direction
		if fmod(time_extant, 5) == 0:
			health -= 0.5
			print("burnt")
	else:
		$Sprite2D.visible = false
		
	move_and_slide()

func player_collided(collision: String) -> void:
	pass
	if collision == "top":
		#print("stunned ", self.name)
		velocity = Vector2(0, 100)
		stunned = true
		stun_timer = .347
	elif collision == "face":
		pass
	elif collision == "slide":
		#print("slid into", self.name)
		velocity = Vector2(0, -500)
		stunned = true
		stun_timer = 1.22

func proj_collided(id: String, vel: Vector2) -> void:
	stunned = true
	stun_timer = .25
	velocity.x += 50*vel.normalized().x
	velocity.y = -200
	match id:
		"10":
			health -= 2
		"20":
			velocity.x -= 2*velocity.length()
			velocity.y = -400
			health -= 9
		"210", "102":
			stun_timer += 2
		"30":
			health -= 1
			stun_timer += 1
		"40":
			health -= 0.5
		"50":
			if is_on_floor():
				velocity.y = -500
			else:
				velocity.y = 500
			health -= 1	
		"60":
			health -=0.5
			if health <= 0:
				freeze()
		"70":
			health -= 1
		"E0":
			health -= 0.5
		"80":
			health -= 1
		"90":
			health -= 2
		"100":
			health -= 3
		"B00M":
			velocity.x += 2*velocity.length()
			velocity.y = -400
			health -= 1
		_:
			pass

func _on_aoe_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemy Hitboxes"):
		var brusho := area.get_parent()
		brusho.shock(shocks + 1, position)
		$AOE.set_deferred("monitoring", false)
		await  get_tree().create_timer(0.1).timeout
	elif area.is_in_group("Fans"):
		cast = area.get_node("RayCast2D") as RayCast2D
		wind_pushing = true

		#print("chain ", brusho.name)


func _on_aoe_area_exited(area: Area2D) -> void:
	if area.is_in_group("Fans"):
		wind_pushing = false


func _on_ev_p_collision_area_entered(_area: Area2D) -> void:
	pass # Replace with function body.
