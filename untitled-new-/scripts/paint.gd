extends CharacterBody2D

var dye_type = 9#randi()%10 +1
const reglength = 32
var regx = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print($Sprite2D.texture.get_size())
	$Sprite2D.region_enabled = true
	regx = 32*dye_type
	$Sprite2D.region_rect = Rect2(regx, 0, reglength, reglength)
	print($Sprite2D.region_rect)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += 100*delta
	else:
		velocity.y = -50
	move_and_slide()


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("friendly hitbox"):
		var player = area.get_parent()
		player.power_up(dye_type+1)
		queue_free()
