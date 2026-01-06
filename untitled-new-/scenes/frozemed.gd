extends CharacterBody2D

var is_hit = false
var slide_accel := 0.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	velocity = Vector2.ZERO


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if is_on_floor() and is_hit:
		var floor_normal = get_floor_normal()
		var ground_angle = rad_to_deg(floor_normal.angle_to((Vector2.UP)))
		if ground_angle > 2 or ground_angle < -2:
			slide_accel = min(slide_accel + 10 * delta, 2000) 
		else:
			slide_accel = 1
		var tangent = Vector2(floor_normal.y, -floor_normal.x).normalized()
		if tangent.dot(Vector2.DOWN) < 0:
			tangent = -tangent
		var slope_dir = Vector2(0,1).project(tangent).normalized()
		velocity +=  slope_dir * (200 * slide_accel) * delta
		
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	move_and_slide()
	


func _on_ev_p_collision_area_entered(area: Area2D) -> void:
	if area.is_in_group("friendly hitbox"):
		print("hit")
		var player = area.get_parent() as CharacterBody2D
		is_hit = true
		velocity.x = player.velocity.x * 2
		velocity.y = -200
		await get_tree().create_timer(15).timeout
		queue_free()
		
		
		
