extends Node2D

const Player = preload("res://scenes/characters/Player.tscn")

const Exit = preload("res://scenes/dungeon/ExitDoor.tscn")
const BlueInk = preload("res://scenes/items/BlueInk.tscn")
const Screentone = preload("res://scenes/items/Screentone.tscn")

const BabyZombie = preload("res://scenes/characters/Enemies/BabyZombie/BabyZombie.tscn")
const BossZombie = preload("res://scenes/characters/Enemies/BossZombie/BossZombie.tscn")

const House = preload("res://scenes/props/House.tscn")
const PaintPortal = preload("res://scenes/props/PaintPortal.tscn")

const TreeBig = preload("res://scenes/props/TreeBig.tscn")
const TreeSmall = preload("res://scenes/props/TreeSmall.tscn")
const TreeMedium = preload("res://scenes/props/TreeMedium.tscn")
const Flower = preload("res://scenes/props/Flower.tscn")
const Flower2 = preload("res://scenes/props/Flower2.tscn")


const Cat = preload("res://scenes/characters/Cat2a.tscn")

const CELL_SIZE = 256
const SCALE = .5
const ENEMY_COUNT = 100

var LEVEL = Globals.level
var borders = Rect2(1, 1, 38, 22)
var walker = Globals.current_walker
var map = Globals.current_map

onready var navigation = $Navigation2D
onready var navigationPolygon = $Navigation2D/NavigationPolygonInstance
onready var tileMap = $Navigation2D/NavigationPolygonInstance/TileMap

func _ready():
	_generate_level()
	
func _generate_enemies():
	for i in ENEMY_COUNT:
		var babyZombie = BabyZombie.instance()
		babyZombie.position = walker.get_random_room().position*CELL_SIZE*SCALE
		babyZombie.position.x = babyZombie.position.x + randf()*10.0+1.0 
		add_child(babyZombie)
	
	if Globals.level >= 3:
		var bossZombie = BossZombie.instance()
		add_child(bossZombie)
		bossZombie.position = walker.get_random_room().position*CELL_SIZE*SCALE
		bossZombie.position.x = bossZombie.position.x + randf()*10.0+1.0 

func _generate_nodes(object, count=20, distance=100):
	if tileMap:
		var cells = tileMap.get_used_cells()
		for i in 20:
			var cell = cells[randi() % cells.size()]
			for j in count:
				var obj = object.instance()
				obj.position = cell*CELL_SIZE*SCALE
				while !_is_far_from_player(obj, 100):
					obj.position.x = obj.position.x - randi()%distance+1
					obj.position.y= obj.position.y - randi()%distance+1
				add_child(obj)	
		
func _generate_props():
	var TREE_COUNT = 50
	var FLOWER_COUNT = 10
	var FLOWER2_COUNT = 20
	
	_generate_nodes(Flower, FLOWER_COUNT)
	_generate_nodes(Flower2, FLOWER2_COUNT, 200)
	_generate_nodes(TreeSmall, 10, 300)
	_generate_nodes(TreeBig, 10, 300)
	_generate_nodes(TreeMedium, 10, 300)
			
func _generate_missions():
	var house = House.instance()
	house.position = walker.get_middle_room().position*CELL_SIZE*SCALE
	while !_is_far_from_player(house, 100):
		house.position.x = house.position.x + randf()*100.0+1.0 
		house.position.y = house.position.y + randf()*100.0+1.0 

	if navigation != null:
		navigation.add_child(house)
		
	var paintPortal = PaintPortal.instance()
	paintPortal.position = walker.get_middle_random_room().position*CELL_SIZE*SCALE
	while !_is_far_from_player(paintPortal, 200):
		paintPortal.position.x = paintPortal.position.x + randf()*200.0+1.0 
		paintPortal.position.y = paintPortal.position.y + randf()*200.0+1.0 
	
	if navigation != null:
		navigation.add_child(paintPortal)
	
	var collectedAmount =  Inventory.get_item("Screentone")
	var questAmount = 10
	var toCollectAmount = questAmount - collectedAmount
	if toCollectAmount > 0:
		for i in toCollectAmount:
			var screentone = Screentone.instance()
			screentone.position = walker.get_random_room().position*CELL_SIZE*SCALE
			while !_is_far_from_player(screentone, 100):
				screentone.position.x = screentone.position.x + randf()*100.0+1.0 
				screentone.position.y = screentone.position.y + randf()*100.0+1.0 
			if navigation != null:
				navigation.add_child(screentone)

func _is_far_from_player(object, distance=100):
	var player_position = Globals.player.global_transform.origin
	var hook_position = object.global_transform.origin
	var d = player_position.distance_to(hook_position)
	var is_far_from_player = d > distance
	return is_far_from_player

func _generate_characters():
	var player = Player.instance()
	player.position = map.pop_front()*CELL_SIZE*SCALE
	if Globals.is_in_middle:
		player.position = walker.get_middle_room().position*CELL_SIZE*SCALE
	Globals.player = player
	if navigationPolygon != null:
		navigationPolygon.add_child(player)
	
	var cat = Cat.instance()
	cat.position = map.pop_front()*CELL_SIZE*SCALE
	Globals.cat = cat
	if navigationPolygon != null:
		navigationPolygon.add_child(cat)
		
func _set_map_walker():
	var WALK_SCALE = LEVEL*500
	var walker_ref = weakref(walker)
	var global_walker_ref = weakref(Globals.current_walker)
	if walker == null or Globals.is_reloaded or !walker_ref.get_ref():
		if Globals.current_walker and !global_walker_ref.get_ref():
			Globals.current_walker.queue_free()
		if walker and !walker_ref.get_ref():
			walker.queue_free()
		walker = Walker.new(Vector2(38, 22), borders)
	if map == null or Globals.is_reloaded:
		map = walker.walk(WALK_SCALE)
	Globals.current_walker = walker
	Globals.current_map = map
		
func _generate_level():
	while !map or !walker:
		_set_map_walker()
	var walker_ref = weakref(walker)
	if walker and !walker_ref.get_ref():
		_set_map_walker()
	var exit = Exit.instance()
	exit.position = walker.get_end_room().position*CELL_SIZE*SCALE
	if navigation != null:
		navigation.add_child(exit)
	exit.connect("leaving_level", self, "new_level")
	
	_generate_characters()
	_generate_missions()
	_generate_enemies()
	_generate_props()
	
	if Globals.is_reloaded:
		walker.queue_free()
	_set_cells()
	Globals.is_reloaded = false
	return true

func _set_cells():
	for location in map:
		if tileMap != null:
			tileMap.set_cellv(location, -1)
	
	if tileMap != null:
		tileMap.update_bitmask_region(borders.position, borders.end)
		
func reload_level():
	Globals.is_reloaded = true
	get_tree().reload_current_scene()
	
func new_level():
	Globals.level +=1 
	Globals.is_reloaded = true
	get_tree().reload_current_scene()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		reload_level()
