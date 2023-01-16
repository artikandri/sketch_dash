extends KinematicBody2D


var _current_speed = 0
var _speed
var _max_speed = 4
var _last_acceleration = Vector2()
var _last_movement = Vector2()

onready var player = Globals.player

func _ready():
	_setup_speed()


func _process(_delta):
	_handle_movement()
	_handle_animation()


func _physics_process(delta):
	_calculate_movement(delta)


func _calculate_movement(_delta):
	var move = _last_movement

	if move.x < 0:
		_turn_left()
	elif move.x > 0:
		_turn_right()

	if move == Vector2():
		_current_speed = 0
	else:
		_current_speed = _speed

	var acc = move * _current_speed

	_last_acceleration = acc
	_last_movement = Vector2()


func _turn_right():
	$AnimatedSprite.set_flip_h(true)


func _turn_left():
	$AnimatedSprite.set_flip_h(false)


func is_flipped():
	return $AnimatedSprite.flip_h

func move(move):
	_last_movement = move

func is_touching_floor():
	return test_move(self.transform, Vector2(0, 1))

func _handle_movement():
	# warning-ignore:return_value_discarded
	move_and_slide(_last_acceleration)



func _handle_animation():
	if is_touching_floor():
		if _is_moving():
			$AnimatedSprite.play('running')
		else:
			$AnimatedSprite.play('idle')




func _setup_speed():
	_speed = _max_speed 


# returns true when reaches position
func move_to_position(target):
	var y_distance = abs(position.y -  target.y)
	var direction = position.direction_to(target)
	direction.y = 0

	if abs(direction.x) < 0.5 and y_distance < 10:
		return true
	else:
		move(direction)
		return false


func _is_moving():
	return _current_speed != 0



