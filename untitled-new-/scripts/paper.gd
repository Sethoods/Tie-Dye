extends Area2D

var velocity := Vector2.ZERO

var base_velocity:= Vector2.ZERO

var player

func _ready() -> void:
	if player.direction >= 0:
		base_velocity = Vector2(250, -100)
	else:
		base_velocity = Vector2(-250, -100)
	velocity += player.velocity + base_velocity
	print(velocity)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:	
	velocity.y += gravity/2 * delta
	position += velocity * delta
	rotation += 20 * delta


func _on_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
			queue_free()
