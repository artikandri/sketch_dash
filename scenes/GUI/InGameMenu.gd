extends CanvasLayer

func _ready():
	$Button.connect("pressed", self, "_quit")

func _process(delta):
	$HealthBar.max_value = Globals.max_health
	$HealthBar.value = Globals.health
	$Time.text = Globals.format_time()

func _quit():
	get_tree().change_scene("res://scenes/GUI/Menu.tscn")
