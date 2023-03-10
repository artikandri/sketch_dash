extends KinematicBody2D

class_name enemy

onready var player = Globals.player
var pause = false
signal ready_for_hiding

func _ready():
	add_to_group("enemies")
	$HitBox.connect("area_entered", self, "hitbox")

func _process(_delta):
	emit_signal("ready_for_hiding", self)
	
func delete():
	if name in Globals.dead_enemies:
		queue_free()
