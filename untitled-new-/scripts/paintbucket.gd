extends StaticBody2D

const PAINTBALL = preload("res://scenes/paint.tscn")
const BUCKET_POOL : Array = [0,5]#0,1,2,3,4,5,6,7,8,9]
# Called when the node enters the scene tree for the first time.
func paint_bucket():	
	if $Timer.is_stopped() == true:
		$Timer.start()
		var paint = PAINTBALL.instantiate()
		paint.dye_type = BUCKET_POOL.pick_random()
		get_parent().call_deferred("add_child", paint)
		paint.global_position = position
		paint.position.y -= 8
		
func _on_timer_timeout() -> void:
	$Timer.stop()
