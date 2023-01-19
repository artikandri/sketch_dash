extends CanvasLayer

func _ready():
	pass # Replace with function body.

func _process(_delta):
	$HealthBar.max_value = Globals.max_health
	$HealthBar.value = Globals.health
