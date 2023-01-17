extends enemy

var speed = 110
var friction = 300
var damage = 50
var health = 140
var velocity = Vector2.ZERO
var knockback = Vector2.ZERO
onready var soft_collision = $SoftCollision
const ZOMBIE = preload("res://Enemies/Zombie/Zombie.tscn")
const BABIES = preload("res://Enemies/BossZombie/BossZombieBabies.tscn")

func _physics_process(delta):
	look_at(player.position)
	knockback = knockback.move_toward(Vector2.ZERO, friction * delta)
	knockback = move_and_slide(knockback)
	velocity = position.direction_to(player.position) * speed
	if soft_collision.is_colliding():
		velocity += soft_collision.get_push_vector() * delta * 1000
	velocity = move_and_slide(velocity)

func _on_HitBox_area_entered(area):
	if "BulletArea" in area.name and !pause:
		knockback = area.knockback_vector * 150
		health -= Globals.attack()
		if health < 1:
			Globals.enemy_die(self)
			var babies = BABIES.instance()
			get_parent().add_child(babies)
			babies.global_position = global_position

func _on_HitBox_body_entered(body):
	if body.name == "Player" and !pause:
		$AnimatedSprite.play("attack")
	
func _on_HitBox_body_exited(body):
	if body.name == "Player" and !pause:
		$AnimatedSprite.play("default")

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "attack" and !pause:
		Globals.take_damage(damage)
