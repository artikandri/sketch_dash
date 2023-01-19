extends Area2D

var stars = preload("res://scenes/paint/paricles.tscn")

func _on_Area2D2_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseMotion or event is InputEventMouseButton:
			if event.is_pressed():
				var stars_instance = stars.instance()
				stars_instance.position = event.position
				stars_instance.emitting = true
				add_child(stars_instance)

