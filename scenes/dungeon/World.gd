extends Node2D

const Player = preload("res://scenes/characters/Player.tscn")

const Exit = preload("res://scenes/dungeon/ExitDoor.tscn")
const BlueInk = preload("res://scenes/items/BlueInk.tscn")
const Screentone = preload("res://scenes/items/Screentone.tscn")

const BabyZombie = preload("res://Enemies/BabyZombie/BabyZombie.tscn")
const Zombie = preload("res://Enemies/Zombie/Zombie.tscn")
const BossZombie = preload("res://Enemies/BossZombie/BossZombie.tscn")

const House = preload("res://scenes/props/House.tscn")
const Cat = preload("res://scenes/characters/Cat.tscn")
const Cat2 = preload("res://scenes/characters/Cat2.tscn")

const AstarCat = preload("res://scenes/AstarCatOuter.tscn")

const CELL_SIZE = 256
const SCALE = .5
const ENEMY_COUNT = 100
const MEDIUM_ENEMY_COUNT = 100

var rng = RandomNumberGenerator.new()
var LEVEL = Globals.level
var borders = Rect2(1, 1, 38, 22)

onready var tileMap = $Navigation2D/TileMap

func _ready():
	randomize()
	rng.randomize()
	_generate_level()
	
func _generate_enemies(map, walker):
	for i in ENEMY_COUNT:
		var babyZombie = BabyZombie.instance()
		add_child(babyZombie)
		babyZombie.position = walker.get_random_room().position*CELL_SIZE*SCALE
	
	if Globals.level > 3:
		for i in MEDIUM_ENEMY_COUNT:
			var zombie = Zombie.instance()
			add_child(zombie)
			zombie.position = walker.get_random_room().position*CELL_SIZE*SCALE
			
func _generate_first_level(map, walker):
	if(Globals.level == 1):
		var house = House.instance()
		add_child(house)
		house.position = walker.get_random_room().position*CELL_SIZE*SCALE
	
		var screentone = Screentone.instance()
		add_child(screentone)
		screentone.position = map.front()*CELL_SIZE*SCALE

func _generate_level():
	var walker = Walker.new(Vector2(38, 22), borders)
	var WALK_SCALE = LEVEL*500
	var map = walker.walk(WALK_SCALE)
	
	var player = Player.instance()
	Globals.player = player
	add_child(player)
	player.position = map.front()*CELL_SIZE*SCALE

	var cat = Cat.instance()
	add_child(cat)
	Globals.cat = cat
	cat.position = map.front()*CELL_SIZE*SCALE
	
	var exit = Exit.instance()
	add_child(exit)
	exit.position = walker.get_end_room().position*CELL_SIZE*SCALE
	exit.connect("leaving_level", self, "new_level")
	
	_generate_first_level(map, walker)
	_generate_enemies(map, walker)
	
	walker.queue_free()
	for location in map:
		if tileMap != null:
			tileMap.set_cellv(location, -1)
	
	if tileMap != null:
		tileMap.update_bitmask_region(borders.position, borders.end)
	return true

func reload_level():
	get_tree().reload_current_scene()
	
func new_level():
	Globals.level +=1 
	get_tree().reload_current_scene()

# debugging purpose 
func _input(event):
	if event.is_action_pressed("ui_accept"):
		reload_level()
