extends Control

var lapsed = 0
var animate_text = false
onready var text = $VBoxContainer/Text
onready var animation_player = $AnimationPlayer

func _ready():
	text.text = (
		"Thank you for playing! You died "
		+ String(Globals.deaths)
		+ " time"
		+ use_s(Globals.deaths)
		+ ", killed "
		+ String(Globals.dead_enemies.size())
		+ " enemies"
	)
	animation_player.connect("animation_finished", self, "_start_text")
	
func _process(delta):
	if animate_text:
		lapsed += delta
	text.visible_characters = lapsed / 0.03

func _on_new_game_pressed():
	Globals.reset_data()
	get_tree().change_scene("res://scenes/levels/Menu.tscn")
	
func _start_text(_anim_name):
	animate_text = true

func use_s(amount):
	return "" if amount == 1 else "s"
