extends Node2D

const Player = preload("res://scenes/characters/Player.tscn")
const Cat2 = preload("res://scenes/characters/Cat2.tscn")
const Exit = preload("res://scenes/dungeon/ExitDoor.tscn")
const Item = preload("res://scenes/items/Item.tscn")
const BabyZombie = preload("res://Enemies/BabyZombie/BabyZombie.tscn")
const Zombie = preload("res://Enemies/Zombie/Zombie.tscn")
const BossZombie = preload("res://Enemies/BossZombie/BossZombie.tscn")

const House = preload("res://scenes/props/House.tscn")
const Cat = preload("res://scenes/characters/Cat.tscn")


const CELL_SIZE = 256
const SCALE = .5
const ENEMY_COUNT = 100
const MEDIUM_ENEMY_COUNT = 100

var rng = RandomNumberGenerator.new()

var LEVEL = 1

var borders = Rect2(1, 1, 38, 22)

onready var tileMap = $TileMap

func _ready():
	randomize()
	rng.randomize()
	generate_level()
	Globals.level = LEVEL

func generate_level():
	var walker = Walker.new(Vector2(38, 22), borders)
	var WALK_SCALE = LEVEL*500
	var map = walker.walk(WALK_SCALE)
	
	var player = Player.instance()
	Globals.player = player
	add_child(player)
	player.position = map.front()*CELL_SIZE*SCALE
	
	# var cat = Cat.instance()
	# Globals.cat = cat
	# add_child(cat)
	# cat.position = map.front()*CELL_SIZE*SCALE*.95
	
	var cat2 = Cat2.instance()
	add_child(cat2)
	cat2.position = map.front()*CELL_SIZE*SCALE
	
	var exit = Exit.instance()
	add_child(exit)
	exit.position = walker.get_end_room().position*CELL_SIZE*SCALE
	exit.connect("leaving_level", self, "reload_level")
	
	var house = House.instance()
	add_child(house)
	house.position = walker.get_random_room().position*CELL_SIZE*SCALE
	
	
	for i in ENEMY_COUNT:
		var babyZombie = BabyZombie.instance()
		var randomNumber = rng.randf_range(0.0, 10.0)
		add_child(babyZombie)
		babyZombie.position = walker.get_random_room().position*CELL_SIZE*SCALE
	
	walker.queue_free()
	for location in map:
		if tileMap != null:
			tileMap.set_cellv(location, -1)
	
	if tileMap != null:
		tileMap.update_bitmask_region(borders.position, borders.end)
	return true

func reload_level():
	get_tree().reload_current_scene()

# debugging purpose 
"""
func _input(event):
	if event.is_action_pressed("ui_accept"):
		reload_level()
"""
