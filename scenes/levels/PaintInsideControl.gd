extends Control

var imageControl = preload("res://scenes/paint/img.gd").new()

func _ready():
	Quest.accept_quest("Finish the drawing")
	$Button.grab_focus()
	pass

func _on_Button_pressed():
	var has_colored_everything = imageControl.has_colored_everything()
	if has_colored_everything:
		Quest.change_status("Finish the drawing", 2)
		Dialogs.show_dialog("Thank you! You got a beautiful screentone as your reward", "Drawing")
	get_tree().change_scene("res://scenes/levels/Outside.tscn")
	pass # Replace with function body.
	

