extends Position2D

export(float) var SPEED = 200.0

enum STATES { IDLE, FOLLOW }
var _state = null

var path = []
var target_point_world = Vector2()
var target_position = Vector2()

var velocity = Vector2()

func _ready():
	_change_state(STATES.IDLE)


func _change_state(new_state):
	var self_position = get_parent().get_node('Cat').get_global_position()
	var player_position = get_parent().get_node('Player').position
	path = get_parent().get_node('TileMap').find_path(self_position, player_position)
	target_point_world = player_position
	if path:
		target_point_world = path[1]
	_state = new_state


func _process(_delta):
	var arrived_to_next_point = move_to(target_point_world)
	if arrived_to_next_point:
		path.remove(0)
		if len(path) == 0:
			_change_state(STATES.IDLE)
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
	
	return position.distance_to(world_position) < ARRIVE_DISTANCE

