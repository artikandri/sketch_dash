extends Node2D

var world = preload("res://scenes/dungeon/World.gd").new()
var isGenerated =  false

func _ready():
	isGenerated = world._ready()
	
	
	
