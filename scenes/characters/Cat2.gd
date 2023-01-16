extends KinematicBody2D

export(int) var SPEED: int = 40
var velocity: Vector2 = Vector2.ZERO

var path: Array = []	# Contains destination positions
var levelNavigation: Navigation2D = null
# var player = null
onready var player = Globals.player
<<<<<<< HEAD
var player_spotted: bool = true
=======
var player_spotted: bool = false
>>>>>>> 8ebdec4 (feat: animation)

onready var line2d = $Line2D
onready var los = $LineOfSight

func _ready():
	yield(get_tree(), "idle_frame")
	var tree = get_tree()
	if tree.has_group("Navigation2D"):
		levelNavigation = tree.get_nodes_in_group("Navigation2D")[0]
<<<<<<< HEAD

func _physics_process(_delta):
	line2d.global_position = Vector2.ZERO
	if Globals.player != null:
		los.look_at(Globals.player.position)
=======
	# if tree.has_group("Player"):
		# player = tree.get_nodes_in_group("Player")[0]

func _physics_process(delta):
	line2d.global_position = Vector2.ZERO
	if player:
		los.look_at(player.global_position)
>>>>>>> 8ebdec4 (feat: animation)
		check_player_in_detection()
		if player_spotted:
			generate_path()
			navigate()
	move()

func check_player_in_detection() -> bool:
	var collider = los.get_collider()
<<<<<<< HEAD
	if collider and collider.is_in_group("player"):
		player_spotted = true
=======
	if collider and collider.is_in_group("Player"):
		player_spotted = true
		print("raycast collided")	# Debug purposes
>>>>>>> 8ebdec4 (feat: animation)
		return true
	return false

func navigate():	# Define the next position to go to
	if path.size() > 0:
		velocity = global_position.direction_to(path[1]) * SPEED
		
		# If reached the destination, remove this point from path array
		if global_position == path[0]:
			path.pop_front()

func generate_path():	# It's obvious
<<<<<<< HEAD
	if levelNavigation != null and Globals.player != null:
		path = levelNavigation.get_simple_path(position, Globals.player.position, false)
=======
	if levelNavigation != null and player != null:
		path = levelNavigation.get_simple_path(global_position, player.global_position, false)
>>>>>>> 8ebdec4 (feat: animation)
		line2d.points = path

func move():
	velocity = move_and_slide(velocity)
