extends Area2D

export(String, FILE, "*.tscn") var to_scene = ""
export(String) var spawnpoint = ""

func _ready():
	# warning-ignore:return_value_discarded
	connect("body_entered", self, "_on_body_entered")
	pass # Replace with function body.

func _on_body_entered(body):
	if body is Player:
		if Globals.has_finished_quest():
			Globals.spawnpoint = spawnpoint
			Globals.is_reloaded = true
			Globals.level +=1
			Globals.current_level = to_scene
			Globals.load_level()
		else:
			Dialogs.show_dialog("Sorry, please finish the quests first.", "exit door")
	pass
