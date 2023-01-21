extends Control

onready var button = $VBoxContainer/Button

func _ready():
	if button:
		button.grab_focus()
	pass

func _on_Button_pressed():
	if get_tree().change_scene("res://scenes/levels/Menu.tscn") != OK:
		push_error("Error changing scene")
	pass # Replace with function body.
