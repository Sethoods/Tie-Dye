extends CharacterBody2D

var base_velocity:= Vector2.ZERO
var saved_dir := 1
var player
var id
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	id = str(player.primary_dye) + str(player.secondary_dye)
	print(id)
	base_velocity = Vector2(250*player.proj_dir[0], -100*(player.proj_dir[1]+1))
	saved_dir=player.proj_dir[0]
	velocity.x += base_velocity.x + player.velocity.x
	velocity.y += base_velocity.y
	
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

		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			var normal = collision.get_normal()
			
			var tangent = Vector2(normal.y, -normal.x).normalized()
			
			if tangent.dot(velocity) < 0:
				tangent = -tangent
			
			var speed = velocity.length()
			
			velocity = tangent*speed
			velocity += -normal * 300
			
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
