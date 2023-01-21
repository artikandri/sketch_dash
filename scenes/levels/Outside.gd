extends Node2D

var world = preload("res://scenes/dungeon/World.gd").new()

func _ready():
	world._ready()
	_set_quests_status()
	
func _set_quests_status():
	if (Inventory.get_item("Beautiful screentone") <= 0): 
		Quest.accept_quest("Finish the drawing")
	else:
		Quest.change_status("Finish the drawing", 2)
	
		
	
	
