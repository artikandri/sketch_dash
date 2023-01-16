extends KinematicBody2D

export(int) var SPEED: int = 40
var velocity: Vector2 = Vector2.ZERO

var path: Array = []	# Contains destination positions
var levelNavigation: Navigation2D = null
var player = Globals.player
var player_spotted: bool = true

onready var line2d = $Line2D
onready var los = $LineOfSight

func _ready():
	yield(get_tree(), "idle_frame")
	var tree = get_tree()
	if tree.has_group("Navigation2D"):
		levelNavigation = tree.get_nodes_in_group("Navigation2D")[0]

func _physics_process(_delta):
	line2d.global_position = Vector2.ZERO
	var player_position = get_parent().get_node('Player').position
	if player:
		los.look_at(player_position)
		check_player_in_detection()
		if player_spotted:
			generate_path()
			navigate()
	move()

func check_player_in_detection() -> bool:
	var collider = los.get_collider()
	if collider and collider.is_in_group("player"):
		player_spotted = true
		return true
	return false

func navigate():	# Define the next position to go to
	if path.size() > 0:
		velocity = global_position.direction_to(path[1]) * SPEED
		if global_position == path[0]:
			path.pop_front()

func generate_path():	# It's obvious
	if levelNavigation != null and player != null:
		var self_position = get_parent().get_node('Cat').get_global_position()
		var player_position = get_parent().get_node('Player').position
		print(get_global_position(), player_position)
		path = levelNavigation.get_simple_path(get_global_position(), player_position, false)
		print(path)
		line2d.points = path

func move():
	velocity = move_and_slide(velocity)
