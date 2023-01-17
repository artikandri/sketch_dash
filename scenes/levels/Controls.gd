extends Control

func _ready():
	$Button.grab_focus()
	pass

func _input(event):
	if(Input.is_action_pressed("ui_click")):
		get_tree().change_scene("res://scenes/levels/Outside.tscn")		
	
func _on_Button_pressed():
	print("test")
	if get_tree().change_scene("res://scenes/levels/Outside.tscn") != OK:
		push_error("Error changing scene")
	pass # Replace with function body.
