extends Node2D

const Player = preload("res://scenes/characters/Player.tscn")

const Exit = preload("res://scenes/dungeon/ExitDoor.tscn")
const BlueInk = preload("res://scenes/items/BlueInk.tscn")
const Screentone = preload("res://scenes/items/Screentone.tscn")

const BabyZombie = preload("res://Enemies/BabyZombie/BabyZombie.tscn")
const BossZombie = preload("res://Enemies/BossZombie/BossZombie.tscn")

const House = preload("res://scenes/props/House.tscn")
const TreeBig = preload("res://scenes/props/TreeBig.tscn")

const Cat = preload("res://scenes/characters/Cat2a.tscn")

const CELL_SIZE = 256
const SCALE = .5
const ENEMY_COUNT = 100

var LEVEL = Globals.level
var borders = Rect2(1, 1, 38, 22)

onready var navigation = $Navigation2D
onready var navigationPolygon = $Navigation2D/NavigationPolygonInstance
onready var tileMap = $Navigation2D/NavigationPolygonInstance/TileMap

func _ready():
	_generate_level()
	
func _generate_enemies(map, walker):
	for i in ENEMY_COUNT:
		var babyZombie = BabyZombie.instance()
		add_child(babyZombie)
		babyZombie.position = walker.get_random_room().position*CELL_SIZE*SCALE
	
	if Globals.level > 3:
		var bossZombie = BossZombie.instance()
		add_child(bossZombie)
		bossZombie.position = walker.get_random_room().position*CELL_SIZE*SCALE
		
func _generate_props(map, walker):
	var TREE_COUNT = 10
	for i in TREE_COUNT:
		var treeBig = TreeBig.instance()
		treeBig.position = walker.get_random_room().position*CELL_SIZE*SCALE
		treeBig.position.x = treeBig.position.x - randf()*10.0+1.0 
		add_child(treeBig)
	
			
func _generate_missions(map, walker):
	var house = House.instance()
	house.position = walker.get_first_room().position*CELL_SIZE*SCALE
	if navigation != null:
		navigation.add_child(house)
	
	var collectedAmount =  Inventory.get_item("Screentone")
	var questAmount = 10
	var toCollectAmount = questAmount - collectedAmount
	if toCollectAmount > 0:
		for i in toCollectAmount:
			var screentone = Screentone.instance()
			screentone.position =walker.get_random_room().position*CELL_SIZE*SCALE
			if navigation != null:
				navigation.add_child(screentone)

func _generate_level():
	var walker = Walker.new(Vector2(38, 22), borders)
	var WALK_SCALE = LEVEL*500
	var map = walker.walk(WALK_SCALE)
	
	var player = Player.instance()
	player.position = walker.get_first_room().position*CELL_SIZE*SCALE
	Globals.player = player
	if navigationPolygon != null:
		navigationPolygon.add_child(player)
	
	var cat = Cat.instance()
	cat.position = walker.get_first_room().position*CELL_SIZE*SCALE
	Globals.cat = cat
	if navigationPolygon != null:
		navigationPolygon.add_child(cat)
	
	var exit = Exit.instance()
	exit.position = walker.get_end_room().position*CELL_SIZE*SCALE
	if navigation != null:
		navigation.add_child(exit)
	exit.connect("leaving_level", self, "new_level")
	
	_generate_missions(map, walker)
	_generate_enemies(map, walker)
	_generate_props(map, walker)
	
	
	walker.queue_free()
	_set_cells(map)
	return true

func _set_cells(map):
	for location in map:
		if tileMap != null:
			tileMap.set_cellv(location, -1)
	
	if tileMap != null:
		tileMap.update_bitmask_region(borders.position, borders.end)
		
func reload_level():
	get_tree().reload_current_scene()
	
func new_level():
	Globals.level +=1 
	get_tree().reload_current_scene()

# debugging purpose 
func _input(event):
	if event.is_action_pressed("ui_accept"):
		reload_level()
