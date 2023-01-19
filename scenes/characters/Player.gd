extends KinematicBody2D

class_name Player

"""
This implements a very rudimentary state machine. There are better implementations
in the AssetLib if you want to make something more complex. Also it shares code with Enemy.gd
and probably both should extend some parent script
"""

export(int) var WALK_SPEED = 350 # pixels per second
export(int) var ROLL_SPEED = 1000 # pixels per second
export(int) var hitpoints = 3

const BULLET = preload("res://scenes/items/Bullet/Bullet.tscn")

signal health_changed(current_hp)

enum { STATE_BLOCKED, STATE_IDLE, STATE_WALKING, STATE_ATTACK, STATE_ROLL, STATE_DIE, STATE_HURT }

export(String, "up", "down", "left", "right") var facing = "down"

var despawn_fx = preload("res://scenes/misc/DespawnFX.tscn")
var anim = ""
var new_anim = ""
var linear_vel = Vector2()
var roll_direction = Vector2.DOWN
var state = STATE_IDLE

# Move the player to the corresponding spawnpoint, if any and connect to the dialog system
func _ready():
	Globals.player = self
	var spawnpoints = get_tree().get_nodes_in_group("spawnpoints")
	for spawnpoint in spawnpoints:
		if spawnpoint.name == Globals.spawnpoint:
			global_position = spawnpoint.global_position
			break
	if not (
			Dialogs.connect("dialog_started", self, "_on_dialog_started") == OK and
			Dialogs.connect("dialog_ended", self, "_on_dialog_ended") == OK ):
		printerr("Error connecting to dialog system")
	pass


func _physics_process(_delta):
	match state:
		STATE_BLOCKED:
			new_anim = "idle_" + facing
			pass
		STATE_IDLE:
			if (
					Input.is_action_pressed("move_down") or
					Input.is_action_pressed("move_left") or
					Input.is_action_pressed("move_right") or
					Input.is_action_pressed("move_up")
				):
					state = STATE_WALKING
			if Input.is_action_just_pressed("attack"):
				state = STATE_ATTACK
			if Input.is_action_just_pressed("roll"):
				state = STATE_ROLL
				roll_direction = Vector2(
						- int( Input.is_action_pressed("move_left") ) + int( Input.is_action_pressed("move_right") ),
						-int( Input.is_action_pressed("move_up") ) + int( Input.is_action_pressed("move_down") )
					).normalized()
				_update_facing()
			new_anim = "idle_" + facing
			pass
		STATE_WALKING:
			if Input.is_action_just_pressed("attack"):
				state = STATE_ATTACK
			if Input.is_action_just_pressed("roll"):
				state = STATE_ROLL
			
			linear_vel = move_and_slide(linear_vel)
			
			var target_speed = Vector2()
			
			if Input.is_action_pressed("move_down"):
				target_speed += Vector2.DOWN
			if Input.is_action_pressed("move_left"):
				target_speed += Vector2.LEFT
			if Input.is_action_pressed("move_right"):
				target_speed += Vector2.RIGHT
			if Input.is_action_pressed("move_up"):
				target_speed += Vector2.UP
			
			target_speed *= WALK_SPEED
			linear_vel = linear_vel.linear_interpolate(target_speed, 0.9)
			# linear_vel = target_speed
			roll_direction = linear_vel.normalized()
			
			_update_facing()
			
			if linear_vel.length() > 5:
				new_anim = "walk_" + facing
			else:
				goto_idle()
			pass
		STATE_ATTACK:
			new_anim = "slash_" + facing
			var current_bullets = Globals.bullets
			while current_bullets > 0:
				current_bullets -= 1
				var direction = roll_direction.normalized()
				var bullet = BULLET.instance()
				get_parent().add_child(bullet)
				bullet.global_position = direction * 100 + global_position
				bullet.set_ball_direction(direction)
				yield(get_tree().create_timer(0.07), "timeout")
			pass
		STATE_ROLL:
			if roll_direction == Vector2.ZERO:
				state = STATE_IDLE
			else:
				linear_vel = move_and_slide(linear_vel)
				var target_speed = Vector2()
				target_speed = roll_direction
				target_speed *= ROLL_SPEED
				#linear_vel = linear_vel.linear_interpolate(target_speed, 0.9)
				linear_vel = target_speed
				new_anim = "roll"
		STATE_DIE:
			new_anim = "die"
		STATE_HURT:
			new_anim = "hurt"
	
	Globals.player_state = state
	## UPDATE ANIMATION
	if new_anim != anim:
		anim = new_anim
		Globals.player_anim = anim
		$anims.play(anim)
	pass

func _on_dialog_started():
	state = STATE_BLOCKED

func _on_dialog_ended():
	state = STATE_IDLE

func goto_idle():
	linear_vel = Vector2.ZERO
	new_anim = "idle_" + facing
	state = STATE_IDLE

func _update_facing():
	if Input.is_action_pressed("move_left"):
		facing = "left"
	if Input.is_action_pressed("move_right"):
		facing = "right"
	if Input.is_action_pressed("move_up"):
		facing = "up"
	if Input.is_action_pressed("move_down"):
		facing = "down"
	Globals.player_facing = facing

func despawn():
	var despawn_particles = despawn_fx.instance()
	get_parent().add_child(despawn_particles)
	despawn_particles.global_position = global_position
	hide()
	yield(get_tree().create_timer(5.0), "timeout")
	get_tree().reload_current_scene()
	pass

func _on_hurtbox_area_entered(area):
	if state != STATE_DIE and Globals.damage < 2:
		# hitpoints -= 1s
		emit_signal("damage_changed", Globals.damage)
		emit_signal("health_changed", Globals.health)
		var pushback_direction = (global_position - area.global_position).normalized()
		move_and_slide( pushback_direction * 5000)
		state = STATE_HURT
		if Globals.health <= 0:
			state = STATE_DIE
	pass
