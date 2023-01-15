extends MovingNpc

var speed = 120
var friction = 150
var velocity = Vector2.ZERO
var knockback = Vector2.ZERO
export(String) var character_name = "Cat"

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, friction * delta)
	knockback = move_and_slide(knockback)
	velocity = position.direction_to(player.position) * speed
	velocity = move_and_slide(velocity)

