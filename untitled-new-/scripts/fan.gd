extends Area2D

@export var fan_particle = preload("res://scenes/particle.tscn")
var timer : float
var player : CharacterBody2D

func direct(dir: Vector2i):
	rotation = atan2(dir.x, -dir.y)
	$RayCast2D.target_position = 50*Vector2(-dir.x, -dir.y)
	
func _ready() -> void:
	player = get_parent().get_parent().get_node("player")

func _process(delta: float) -> void:
	timer += delta
	if fmod(timer, 10*delta)  <= 0.025 and player.position.x - position.x <= 125 and player.position.x - position.x >= -125:
		var particle = fan_particle.instantiate()
		get_parent().add_child(particle)
		particle.fan = self
		if $RayCast2D.target_position.normalized() == Vector2.UP or $RayCast2D.target_position.normalized() == Vector2.DOWN:
			particle.global_position = Vector2(position.x+ randi_range(-30, 30), position.y)
		else:
			particle.global_position = Vector2(position.x, position.y+ randi_range(-30, 30))
		await get_tree().create_timer(1).timeout
		particle.queue_free()
	
