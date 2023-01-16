extends KinematicBody2D

export(float) var SPEED = 350

export(String, "up", "down", "left", "right") var facing = "down"
enum STATES { DOWN_IDLE, DOWN, SIDE, SIDE_IDLE, UP, UP_IDLE }
enum PLAYER_STATES { STATE_BLOCKED, STATE_IDLE, STATE_WALKING, STATE_ATTACK, STATE_ROLL, STATE_DIE, STATE_HURT }
var _state = null

var path = []
var target_point_world = Vector2()
var target_position = Vector2()
var velocity = Vector2()
var distance = 50


func _ready():
	_change_state(STATES.DOWN_IDLE)


func _change_state(new_state):
	var self_position = get_node("/root/Outside/World/Navigation2D/NavigationPolygonInstance/Cat").get_global_position()
	var player_position = get_node("/root/Outside/World/Navigation2D/NavigationPolygonInstance/Player").position
	player_position.y = player_position.y + distance
	player_position.x = player_position.x + distance
	var tileMap = get_node("/root/Outside/World/Navigation2D/NavigationPolygonInstance/TileMap")
	if tileMap:
		path = tileMap.find_path(self_position, player_position)
	target_point_world = player_position
	if path:
		target_point_world = path[1]
	_state = new_state


func _process(_delta):
	var arrived_to_next_point = move_to(target_point_world)
	if arrived_to_next_point:
		if path:
			path.remove(0)
		if len(path) == 0:
			_change_state(STATES.DOWN_IDLE)
			return
		target_point_world = path[0]

func move_to(world_position):
	var MASS = 10.0
	var ARRIVE_DISTANCE = 10.0
	var desired_velocity = (world_position - position).normalized() * SPEED
	var steering = desired_velocity - velocity
	velocity += steering / MASS
	position += velocity * get_process_delta_time()  
	
	# rotation = velocity.angle()
	if (Globals.player_state == PLAYER_STATES.STATE_IDLE):
		if (Globals.player_facing == "down"):
			$AnimatedSprite.play("Idle")
		if (Globals.player_facing == "up"):
			$AnimatedSprite.play("UpIdle")
		if (Globals.player_facing == "left"):
			$AnimatedSprite.play("LeftIdle")
		if (Globals.player_facing == "right"):
			$AnimatedSprite.play("RightIdle")
	else:
		if (Globals.player_facing == "down"):
			$AnimatedSprite.play("Down")
		if (Globals.player_facing == "up"):
			$AnimatedSprite.play("Up")
		if (Globals.player_facing == "left"):
			$AnimatedSprite.play("Left")
		if (Globals.player_facing == "right"):
			$AnimatedSprite.play("Right")
	
	return position.distance_to(world_position) < ARRIVE_DISTANCE

