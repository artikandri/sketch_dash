extends Node

var imageControl = preload("res://scenes/paint/img.gd").new()
var has_showed_dialog = false

func _on_Clean_pressed():
	imageControl.clean()

func _on_Finish_pressed():
	var has_colored_everything = imageControl.has_colored_everything()
	if has_colored_everything:
		Quest.change_status("Finish the drawing", 2)
		Inventory.add_item("Beautiful screentone", 1)
		if !has_showed_dialog:
			Dialogs.show_dialog("Thank you! You got a beautiful screentone as your reward", "Drawing")
			has_showed_dialog = true
	
	if has_showed_dialog:	
		get_tree().change_scene("res://scenes/levels/Outside.tscn")
	
