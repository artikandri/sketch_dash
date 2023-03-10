extends Node

# warning-ignore:unused_class_variable
var spawnpoint = ""
var bullets = 2
var damage = 2
var health = 100
var max_health = 100
var dead_enemies = []
var rng = RandomNumberGenerator.new()
var deaths = 0
var time = 0
var facing
var anim 
var player
var cat
var player_state
var player_anim
var player_facing
var current_level = ""
var current_map
var current_walker = null
var img_id = 1
var brush = false
var painting_type = "color_fill" 
var level : int = 1
var is_in_middle = false
var is_reloaded = false

func _ready():
	VisualServer.set_default_clear_color(ColorN("white"))

func take_damage(dmg):
	var dmg_taken = rng.randi_range(dmg, dmg + 3)
	health -= dmg_taken
	if health < 1:
		deaths += 1
		load_level()
	return dmg_taken
	
func attack():
	if rng.randi_range(0, 10) < 3:
		return damage + 6
	else:
		return rng.randi_range(damage, damage + 2)
		
func go_to_upper_level():
	if level >5:
		end_game()
		return
	level +=1 
	current_map = null
	current_walker = null
	bullets = 2*level
	damage = 2*level
	max_health = 100
	dead_enemies = []
	deaths = 0
	get_tree().call_group("enemies", "delete")	
	call_deferred("_deferred_goto_scene", "res://scenes/levels/Outside.tscn", false)
		
func load_level(new = false):
	call_deferred("_deferred_goto_scene", "res://scenes/levels/Outside.tscn", new)

func _deferred_goto_scene(path, new):
	var root = get_tree().get_root()
	root.get_child(root.get_child_count() - 1).free()
	var s = ResourceLoader.load(path)
	var current_scene = s.instance()
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)
	if new:
		bullets = 2
		damage = 2
		max_health = 100
		dead_enemies = []
		deaths = 0
		time = 0
		level = 1
		current_map = null
		current_walker = null
		is_in_middle = false
		is_reloaded = false
	health = max_health
	get_tree().call_group("enemies", "delete")	

func reset_data():
	bullets = 2
	damage = 2
	max_health = 100
	dead_enemies = []
	deaths = 0
	time = 0
	level = 1
	current_map = null
	current_walker = null
	health = max_health
	current_level = ""
	get_tree().call_group("enemies", "delete")	

func end_game():
	get_tree().change_scene("res://scenes/GUI/GameOver.tscn")

func has_finished_quest():
	var has_finished = true
	if level >= 1:
		has_finished = has_finished && (Inventory.get_item("Blue ink") >= 1) && (Inventory.get_item("Beautiful screentone") >= 1)
	return has_finished

func enemy_die(enemy):
	dead_enemies.append(enemy.name)
	enemy.queue_free()

"""
Really simple save file implementation. Just saving some variables to a dictionary
"""
func save_game(): 
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	var save_dict = {}
	save_dict.spawnpoint = spawnpoint
	save_dict.current_level = current_level
	save_dict.inventory = Inventory.list()
	save_dict.quests = Quest.get_quest_list()
	save_game.store_line(to_json(save_dict))
	save_game.close()
	pass

"""
If check_only is true it will only check for a valid save file and return true or false without
restoring any data
"""
func load_game(check_only=false):
	var save_game = File.new()
	
	if not save_game.file_exists("user://savegame.save"):
		return false
	
	save_game.open("user://savegame.save", File.READ)
	
	var save_dict = parse_json(save_game.get_line())
	if typeof(save_dict) != TYPE_DICTIONARY:
		return false
	if not check_only:
		_restore_data(save_dict)
	
	save_game.close()
	return true

"""
Restores data from the JSON dictionary inside the save files
"""
func _restore_data(save_dict):
	# JSON numbers are always parsed as floats. In this case we need to turn them into ints
	for key in save_dict.quests:
		save_dict.quests[key] = int(save_dict.quests[key])
	Quest.quest_list = save_dict.quests
	
	# JSON numbers are always parsed as floats. In this case we need to turn them into ints
	for key in save_dict.inventory:
		save_dict.inventory[key] = int(save_dict.inventory[key])
	Inventory.inventory = save_dict.inventory
	
	spawnpoint = save_dict.spawnpoint
	current_level = save_dict.current_level
	pass
	
