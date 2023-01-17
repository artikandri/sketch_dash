extends Control

func _ready():
	$Button.grab_focus()
	pass

func _on_Button_pressed():
	# continue
	get_tree().change_scene("res://scenes/levels/Outside.tscn")
	pass # Replace with function body.
	

